// Edge Function: gera rascunho de conteúdo (história + curiosidades) para um ponto.
// GPT (OpenAI) como principal, Gemini como backup. Chaves ficam em segredos do
// servidor — nunca no navegador. Só organizador autorizado pode chamar.

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { ...cors, "Content-Type": "application/json" } });
}

function emailFromJWT(token: string): string | null {
  try {
    const payload = JSON.parse(atob(token.split(".")[1].replace(/-/g, "+").replace(/_/g, "/")));
    return payload.email || null;
  } catch { return null; }
}

async function isOrganizer(email: string): Promise<boolean> {
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !key) return false;
  const r = await fetch(`${url}/rest/v1/organizers?select=email&email=eq.${encodeURIComponent(email)}`, {
    headers: { apikey: key, Authorization: `Bearer ${key}` },
  });
  if (!r.ok) return false;
  const j = await r.json();
  return Array.isArray(j) && j.length > 0;
}

function buildPrompt(name: string, kind?: string): string {
  return `Você cataloga pontos culturais/turísticos para um roteiro. Sobre "${name}"${kind ? ` (${kind})` : ""}, gere um rascunho em português do Brasil.
Responda SOMENTE com JSON válido neste formato:
{"body":"história em 2 a 4 frases, factual","chips":["destaque curto","destaque curto"],"curios":[{"h":"título curto","p":"curiosidade em 1-2 frases"},{"h":"título curto","p":"curiosidade em 1-2 frases"}]}
Seja preciso. Se não tiver certeza de uma data, autor ou fato específico, mantenha geral e verdadeiro — NÃO invente. É um rascunho que será revisado por uma pessoa.`;
}

function parseDraft(txt: string | undefined) {
  if (!txt) return null;
  try {
    const m = txt.match(/\{[\s\S]*\}/);
    const obj = JSON.parse(m ? m[0] : txt);
    return {
      body: String(obj.body || ""),
      chips: Array.isArray(obj.chips) ? obj.chips.slice(0, 4).map((c: unknown) => String(c)) : [],
      curios: Array.isArray(obj.curios)
        ? obj.curios.slice(0, 2).map((c: any) => ({ h: String(c?.h || ""), p: String(c?.p || "") }))
        : [],
      _provider: "",
    };
  } catch { return null; }
}

async function tryOpenAI(prompt: string) {
  const key = Deno.env.get("OPENAI_API_KEY");
  if (!key) return null;
  try {
    const r = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [{ role: "user", content: prompt }],
        response_format: { type: "json_object" },
        temperature: 0.5,
      }),
    });
    if (!r.ok) return null;
    const j = await r.json();
    const d = parseDraft(j.choices?.[0]?.message?.content);
    if (d) d._provider = "gpt";
    return d;
  } catch { return null; }
}

async function tryGemini(prompt: string) {
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) return null;
  try {
    const r = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${key}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt + "\nResponda apenas com o JSON." }] }],
          generationConfig: { temperature: 0.5, responseMimeType: "application/json" },
        }),
      },
    );
    if (!r.ok) return null;
    const j = await r.json();
    const d = parseDraft(j.candidates?.[0]?.content?.parts?.[0]?.text);
    if (d) d._provider = "gemini";
    return d;
  } catch { return null; }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "método não permitido" }, 405);

  // Autorização: precisa ser organizador logado
  const auth = req.headers.get("Authorization") || "";
  const email = emailFromJWT(auth.replace("Bearer ", ""));
  if (!email || !(await isOrganizer(email))) return json({ error: "não autorizado" }, 403);

  let name = "", kind = "";
  try { const b = await req.json(); name = String(b.name || "").trim(); kind = String(b.kind || "").trim(); }
  catch { return json({ error: "corpo inválido" }, 400); }
  if (name.length < 2) return json({ error: "informe o nome do ponto" }, 400);

  const prompt = buildPrompt(name, kind);
  let draft = await tryOpenAI(prompt);      // principal
  if (!draft) draft = await tryGemini(prompt); // backup
  if (!draft) return json({ error: "IA indisponível — verifique as chaves OPENAI_API_KEY / GEMINI_API_KEY." }, 502);

  return json(draft, 200);
});
