-- =====================================================================
-- VivaAR — Seed. Recria os roteiros de demonstração num banco novo.
-- Idempotente: pode rodar de novo sem duplicar.
-- =====================================================================

-- Organizador autorizado (allowlist da Edge Function). Ajuste conforme necessário.
insert into public.organizers (email) values ('eldastito@gmail.com')
  on conflict (email) do nothing;

-- Patrocinador de exemplo (usado no roteiro estreia).
insert into public.sponsors (name, message, cta_label, tier)
  select 'Pipoca & Cia', 'Combo bomboniere com 20% de desconto apresentando esta tela.', 'Quero o combo', 'checkpoint'
  where not exists (select 1 from public.sponsors where name = 'Pipoca & Cia');

do $$
declare
  v_env uuid; v_sp uuid; n uuid;
begin
  -- =================================================================
  -- 1) rio-centro — Roteiro Cultural (modelos reais)
  -- =================================================================
  insert into public.environments (slug, name, kind, reward_title, reward_code, cta_label, cta_url)
  values ('rio-centro','Patrimônio em Realidade Aumentada','tourism',
          'Roteiro concluído!','CULTURA-2026',null,null)
  on conflict (slug) do update set name=excluded.name
  returning id into v_env;

  delete from public.experiences where node_id in (select id from public.physical_nodes where environment_id=v_env);
  delete from public.physical_nodes where environment_id=v_env;

  insert into public.physical_nodes (environment_id,label,subtitle,anchor_value,order_index)
  values (v_env,'Theatro Municipal','Rio de Janeiro · Cinelândia · desde 1909','CV:rio-centro:teatro',1) returning id into n;
  insert into public.experiences (node_id,title,body,model_glb_url,model_usdz_url,data) values
    (n,'Theatro Municipal',
     'Inaugurado em <b>14 de julho de 1909</b>, coroou a reforma que abriu a Avenida Central. Projeto inspirado na Ópera de Paris.',
     'teatro-municipal.glb','teatro-municipal.usdz',
     jsonb_build_object('flabel','Fundação',
       'chips',jsonb_build_array('<b>1909</b> inauguração','<b>1905</b> início','estilo <b>eclético</b>'),
       'curios',jsonb_build_array(
         jsonb_build_object('h','Erguido sobre a água','p','Fundado sobre cerca de 1.600 estacas de madeira cravadas no lençol freático.'),
         jsonb_build_object('h','Arte por dentro','p','Eliseu Visconti pintou o teto e o pano de boca; no subsolo, o restaurante Assírio.'))));

  insert into public.physical_nodes (environment_id,label,subtitle,anchor_value,order_index)
  values (v_env,'Pégaso','O cavalo alado das artes','CV:rio-centro:pegaso',2) returning id into n;
  insert into public.experiences (node_id,title,body,model_glb_url,model_usdz_url,data) values
    (n,'Pégaso',
     'Na mitologia grega, <b>Pégaso</b> é o cavalo alado nascido do sangue de Medusa. Símbolo da inspiração poética.',
     'pegasus.glb','pegasus.usdz',
     jsonb_build_object('flabel','O símbolo',
       'chips',jsonb_build_array('mitologia <b>grega</b>','símbolo das <b>artes</b>'),
       'curios',jsonb_build_array(
         jsonb_build_object('h','A fonte das Musas','p','Ao bater o casco no monte Hélicon, fez brotar a fonte Hipocrene.'),
         jsonb_build_object('h','Na Ópera de Paris','p','O Palais Garnier exibe grupos dourados de Pégaso.')),
       'note','Conteúdo simbólico — procedência específica a confirmar.'));

  insert into public.physical_nodes (environment_id,label,subtitle,anchor_value,order_index)
  values (v_env,'Pietat','Museu Frederic Marès · Barcelona','CV:rio-centro:pietat',3) returning id into n;
  insert into public.experiences (node_id,title,body,model_glb_url,model_usdz_url,data) values
    (n,'Pietat',
     'A <b>Pietat</b> — a Virgem amparando o corpo do filho — pertence ao acervo do <b>Museu Frederic Marès</b>, em Barcelona.',
     'pietat.glb','pietat.usdz',
     jsonb_build_object('flabel','A obra',
       'chips',jsonb_build_array('tema <b>Pietà</b>','acervo <b>Marès</b>','digitalização <b>3D</b>'),
       'curios',jsonb_build_array(
         jsonb_build_object('h','O museu de um escultor','p','Frederic Marès (1893–1991) doou à cidade um dos maiores acervos de escultura da Espanha.'),
         jsonb_build_object('h','A joia da casa','p','A peça mais celebrada é a Pietat de Juan de Juni (c. 1537).')),
       'note','Digitalização 3D de acervo. Identificação a confirmar.'));

  -- =================================================================
  -- 2) estreia — Caça aos Heróis (cinema, modelos placeholder)
  -- =================================================================
  select id into v_sp from public.sponsors where name='Pipoca & Cia' limit 1;

  insert into public.environments (slug, name, kind, reward_title, reward_code, cta_label, cta_url)
  values ('estreia','Estreia — Caça aos Heróis','mall',
          'Missão concluída! Você desbloqueou a pré-venda.','ESTREIA20',
          'Comprar ingresso na pré-venda','https://exemplo-cinema.com/pre-venda')
  on conflict (slug) do update set name=excluded.name
  returning id into v_env;

  delete from public.experiences where node_id in (select id from public.physical_nodes where environment_id=v_env);
  delete from public.physical_nodes where environment_id=v_env;

  insert into public.physical_nodes (environment_id,label,subtitle,anchor_value,order_index,sponsor_id)
  values (v_env,'Mulher Invisível','Entrada · portão do cinema','CV:estreia:heroi1',1,v_sp) returning id into n;
  insert into public.experiences (node_id,title,body,model_glb_url,model_usdz_url,data) values
    (n,'Mulher Invisível',
     'A <b>Mulher Invisível</b> (Sue Storm) apareceu na entrada! Ela pode ficar invisível e criar campos de força. Toque em <b>Ver em RA</b>, traga a heroína para o seu lado e <b>tire sua foto</b>.',
     'invisible.glb','invisible.usdz',
     jsonb_build_object('flabel','A heroína',
       'chips',jsonb_build_array('<b>tamanho real</b>','ponto de <b>foto</b>','1 de <b>3</b> heróis'),
       'curios',jsonb_build_array(
         jsonb_build_object('h','Invisibilidade','p','Sue Storm consegue desaparecer e também deixar objetos e pessoas invisíveis.'),
         jsonb_build_object('h','Campos de força','p','Ela cria escudos e plataformas de energia — uma das heroínas mais poderosas.'))));

  insert into public.physical_nodes (environment_id,label,subtitle,anchor_value,order_index)
  values (v_env,'Herói 2','Praça de alimentação','CV:estreia:heroi2',2) returning id into n;
  insert into public.experiences (node_id,title,body,model_glb_url,model_usdz_url,data) values
    (n,'Herói 2','Personagem placeholder 2.','pegasus.glb','pegasus.usdz',
     jsonb_build_object('flabel','Sobre','chips',jsonb_build_array(),
       'curios',jsonb_build_array(jsonb_build_object('h','Nota','p','Modelo placeholder.')),'note','Placeholder.'));

  insert into public.physical_nodes (environment_id,label,subtitle,anchor_value,order_index)
  values (v_env,'Herói 3','Corredor das salas','CV:estreia:heroi3',3) returning id into n;
  insert into public.experiences (node_id,title,body,model_glb_url,model_usdz_url,data) values
    (n,'Herói 3','Personagem placeholder 3.','pegasus.glb','pegasus.usdz',
     jsonb_build_object('flabel','Sobre','chips',jsonb_build_array(),
       'curios',jsonb_build_array(jsonb_build_object('h','Nota','p','Modelo placeholder.')),'note','Placeholder.'));

  -- =================================================================
  -- 3) encantada — Santos Dumont (Petrópolis, modelos placeholder)
  -- =================================================================
  insert into public.environments (slug, name, kind, reward_title, reward_code, cta_label, cta_url)
  values ('encantada','A Encantada — Santos Dumont em RA','museum',
          'Você desvendou A Encantada! Santos Dumont manda lembranças.','DUMONT14',
          'Conhecer o Museu Casa de Santos Dumont','https://exemplo-museu.com/a-encantada')
  on conflict (slug) do update set name=excluded.name
  returning id into v_env;

  delete from public.experiences where node_id in (select id from public.physical_nodes where environment_id=v_env);
  delete from public.physical_nodes where environment_id=v_env;

  insert into public.physical_nodes (environment_id,label,subtitle,anchor_value,order_index)
  values (v_env,'Santos Dumont na escada','A famosa escada que se sobe de um jeito só','CV:encantada:escada',1) returning id into n;
  insert into public.experiences (node_id,title,body,model_glb_url,model_usdz_url,data) values
    (n,'Boas-vindas',
     'Bem-vindo à <b>Encantada</b>! Aqui Santos Dumont projetou tudo à sua maneira — até a escada, que só pode ser subida começando com o <b>pé direito</b>.',
     'pegasus.glb','pegasus.usdz',
     jsonb_build_object('flabel','Boas-vindas',
       'chips',jsonb_build_array('<b>1918</b> a casa','projeto <b>do próprio</b>','escada <b>pé direito</b>'),
       'curios',jsonb_build_array(
         jsonb_build_object('h','Uma casa-invento','p','Santos Dumont chamava a casa de "A Encantada". Cada detalhe é uma solução de engenharia à moda dele.'),
         jsonb_build_object('h','A escada de um pé só','p','Os degraus alternados obrigam a subir sempre começando pelo pé direito.')),
       'note','Personagem 3D provisório (placeholder) — será substituído pelo modelo do Santos Dumont.'));

  insert into public.physical_nodes (environment_id,label,subtitle,anchor_value,order_index)
  values (v_env,'A curiosidade do inventor','Dentro da casa · o relógio de pulso','CV:encantada:interior',2) returning id into n;
  insert into public.experiences (node_id,title,body,model_glb_url,model_usdz_url,data) values
    (n,'O relógio de pulso',
     'Pilotando seus dirigíveis, Santos Dumont não conseguia tirar o relógio do bolso. Pediu ao amigo <b>Louis Cartier</b> um relógio para usar no <b>pulso</b>.',
     'pegasus.glb','pegasus.usdz',
     jsonb_build_object('flabel','A curiosidade',
       'chips',jsonb_build_array('<b>Cartier</b> 1904','relógio de <b>pulso</b>','aviação <b>+</b> moda'),
       'curios',jsonb_build_array(
         jsonb_build_object('h','Do bolso para o pulso','p','A necessidade prática de ver a hora enquanto voava criou o modelo "Santos" da Cartier.'),
         jsonb_build_object('h','Sem patente','p','Fiel ao seu ideal, nunca patenteou suas invenções.')),
       'note','Personagem 3D provisório (placeholder).'));

  insert into public.physical_nodes (environment_id,label,subtitle,anchor_value,order_index)
  values (v_env,'Foto com o 14 Bis','Ponto de selfie · o avião que voou em Paris','CV:encantada:foto',3) returning id into n;
  insert into public.experiences (node_id,title,body,model_glb_url,model_usdz_url,data) values
    (n,'O 14 Bis',
     'Em <b>23 de outubro de 1906</b>, em Paris, o <b>14 Bis</b> fez o primeiro voo público homologado de um mais-pesado-que-o-ar. Traga o avião em RA e <b>tire sua foto</b>.',
     '14bis.glb','14bis.usdz',
     jsonb_build_object('flabel','O 14 Bis',
       'chips',jsonb_build_array('<b>1906</b> Paris','primeiro <b>voo público</b>','ponto de <b>foto</b>'),
       'curios',jsonb_build_array(
         jsonb_build_object('h','Voou de cauda na frente','p','O 14 Bis tinha configuração "canard": asas atrás e leme na frente.'),
         jsonb_build_object('h','60 metros históricos','p','O voo homologado percorreu cerca de 60 metros.'))));
end $$;
