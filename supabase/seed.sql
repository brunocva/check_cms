-- =============================================================================
-- seed.sql
-- Dados de exemplo: 3 matérias, 5 tags e 15 questões (com tags associadas).
--
-- IMPORTANTE: rode este script DEPOIS de criar sua conta pelo formulário de
-- cadastro (/register) do app, pois as linhas precisam de um user_id válido
-- em auth.users. Troque o e-mail abaixo pelo que você usou no cadastro.
--
-- Como rodar: Supabase Studio -> SQL Editor -> cole o conteúdo -> Run.
-- =============================================================================

do $$
declare
  v_user_id uuid;

  v_subj_incendio uuid;
  v_subj_socorros uuid;
  v_subj_emergencia uuid;

  v_tag_calculo uuid;
  v_tag_interpretacao uuid;
  v_tag_legislacao uuid;
  v_tag_memorizacao uuid;
  v_tag_raciocinio uuid;

  v_q uuid;
begin
  -- 1) Troque o e-mail abaixo pelo seu e-mail de cadastro no app.
  select id into v_user_id from auth.users where email = 'seu-email@exemplo.com' limit 1;

  if v_user_id is null then
    raise exception 'Nenhum usuário encontrado com esse e-mail. Cadastre-se no app em /register e edite o e-mail no topo deste arquivo antes de rodar o seed.';
  end if;

  -- 2) Matérias -------------------------------------------------------------
  insert into public.subjects (user_id, name) values (v_user_id, 'Combate a Incêndio')
    on conflict (user_id, name) do update set name = excluded.name
    returning id into v_subj_incendio;

  insert into public.subjects (user_id, name) values (v_user_id, 'Primeiros Socorros')
    on conflict (user_id, name) do update set name = excluded.name
    returning id into v_subj_socorros;

  insert into public.subjects (user_id, name) values (v_user_id, 'Procedimentos de Emergência')
    on conflict (user_id, name) do update set name = excluded.name
    returning id into v_subj_emergencia;

  -- 3) Tags -------------------------------------------------------------------
  insert into public.tags (user_id, name, color) values (v_user_id, 'cálculo', '#3b82f6')
    on conflict (user_id, name) do update set color = excluded.color
    returning id into v_tag_calculo;

  insert into public.tags (user_id, name, color) values (v_user_id, 'interpretação', '#8b5cf6')
    on conflict (user_id, name) do update set color = excluded.color
    returning id into v_tag_interpretacao;

  insert into public.tags (user_id, name, color) values (v_user_id, 'legislação', '#ef4444')
    on conflict (user_id, name) do update set color = excluded.color
    returning id into v_tag_legislacao;

  insert into public.tags (user_id, name, color) values (v_user_id, 'memorização', '#f59e0b')
    on conflict (user_id, name) do update set color = excluded.color
    returning id into v_tag_memorizacao;

  insert into public.tags (user_id, name, color) values (v_user_id, 'raciocínio lógico', '#10b981')
    on conflict (user_id, name) do update set color = excluded.color
    returning id into v_tag_raciocinio;

  -- 4) Questões -----------------------------------------------------------
  -- Combate a Incêndio ------------------------------------------------------
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_incendio,
    'Qual a distância recomendada para apontar o bico do extintor para a base do fogo?',
    '[{"key":"A","text":"0,5 a 1 metro"},{"key":"B","text":"1,5 a 2 metros"},{"key":"C","text":"3 a 4 metros"},{"key":"D","text":"Encostado na chama"}]'::jsonb,
    'B', 'O procedimento padrão indica apontar o bico ejetor para a base do fogo a uma distância de 1,5 a 2 metros, em movimento de varredura.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_incendio,
    'O extintor do toalete (BCF1301) aciona automaticamente ao atingir qual temperatura?',
    '[{"key":"A","text":"50°C"},{"key":"B","text":"65°C"},{"key":"C","text":"77°C"},{"key":"D","text":"100°C"}]'::jsonb,
    'C', 'O extintor instalado no toalete é acionado automaticamente ao atingir 77°C.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_incendio,
    'Fogo em um notebook ainda conectado à energia é classificado em qual classe?',
    '[{"key":"A","text":"Classe A"},{"key":"B","text":"Classe B"},{"key":"C","text":"Classe C"},{"key":"D","text":"Classe D"}]'::jsonb,
    'C', 'Equipamentos elétricos energizados caracterizam fogo Classe C; nunca se deve usar líquidos enquanto a fonte de energia não for desconectada.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_incendio,
    'Quantos extintores portáteis estão instalados na frota do exemplo (A32F)?',
    '[{"key":"A","text":"3 (três)"},{"key":"B","text":"5 (cinco)"},{"key":"C","text":"7 (sete)"},{"key":"D","text":"10 (dez)"}]'::jsonb,
    'B', 'São 05 (cinco) extintores portáteis instalados na frota do exemplo.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_incendio,
    'Cada extintor descarrega totalmente entre 8 e 10 segundos. Descarregando 3 extintores em sequência, sem pausa, qual o tempo total aproximado de descarga?',
    '[{"key":"A","text":"Entre 8 e 10 segundos"},{"key":"B","text":"Entre 16 e 20 segundos"},{"key":"C","text":"Entre 24 e 30 segundos"},{"key":"D","text":"Entre 40 e 50 segundos"}]'::jsonb,
    'C', 'Multiplicando a faixa de 8-10s por 3 extintores obtemos de 24 a 30 segundos de descarga total.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_calculo);

  -- Primeiros Socorros -----------------------------------------------------
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_socorros,
    'Qual a relação compressões:ventilações na RCP em adultos (acima de 8 anos)?',
    '[{"key":"A","text":"15:2"},{"key":"B","text":"30:2"},{"key":"C","text":"5:1"},{"key":"D","text":"10:2"}]'::jsonb,
    'B', 'Para adolescentes e adultos, o ciclo padrão é de 30 compressões para 2 ventilações.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_socorros,
    'Qual a profundidade recomendada para compressões torácicas em um adulto?',
    '[{"key":"A","text":"1 a 2 cm"},{"key":"B","text":"Mínimo de 5 cm, não excedendo 6 cm"},{"key":"C","text":"Exatos 10 cm"},{"key":"D","text":"Não há profundidade definida"}]'::jsonb,
    'B', 'As compressões em adultos devem ter profundidade mínima de 5 cm, sem exceder 6 cm.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_socorros,
    'Trabalhando na frequência recomendada de 100 a 120 compressões por minuto, aproximadamente quantos ciclos completos de 30 compressões cabem em 1 minuto?',
    '[{"key":"A","text":"Entre 1 e 2 ciclos"},{"key":"B","text":"Entre 3 e 4 ciclos"},{"key":"C","text":"Entre 6 e 7 ciclos"},{"key":"D","text":"10 ciclos"}]'::jsonb,
    'B', 'Dividindo 100–120 compressões por 30 (compressões por ciclo) chegamos a aproximadamente 3 a 4 ciclos por minuto.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_calculo);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_socorros,
    'Na escala de Cincinnati (avaliação de AVC), quais três sinais são observados?',
    '[{"key":"A","text":"Febre, tosse e falta de ar"},{"key":"B","text":"Face, força e fala"},{"key":"C","text":"Pulso, pressão e pele"},{"key":"D","text":"Visão, audição e equilíbrio"}]'::jsonb,
    'B', 'A escala avalia assimetria facial, força motora (queda de braço) e alteração de fala — mnemônico "Face, força e fala".', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_socorros,
    'Uma vítima apresenta pulso rápido e fino, pele pálida, fria e úmida, e queda no nível de consciência. Qual quadro é mais provável?',
    '[{"key":"A","text":"Convulsão"},{"key":"B","text":"Choque hipovolêmico"},{"key":"C","text":"Hiperglicemia"},{"key":"D","text":"Enjoo comum"}]'::jsonb,
    'B', 'Pulso rápido e fino associado a pele pálida, fria e úmida e alteração de consciência são sinais clássicos de choque (geralmente hipovolêmico).', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  -- Procedimentos de Emergência --------------------------------------------
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_emergencia,
    'Segundo a Lei do Aeronauta (Lei 13.475/2017), qual o limite de horas mensais de voo citado no material de estudo?',
    '[{"key":"A","text":"60 horas"},{"key":"B","text":"90 horas"},{"key":"C","text":"120 horas"},{"key":"D","text":"176 horas"}]'::jsonb,
    'B', 'O limite mensal de horas de voo referenciado é de 90 horas em 28 dias.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_emergencia,
    'Qual o limite máximo de horas anuais de voo citado no material de estudo?',
    '[{"key":"A","text":"600 horas"},{"key":"B","text":"750 horas"},{"key":"C","text":"900 horas"},{"key":"D","text":"1000 horas"}]'::jsonb,
    'C', 'O limite anual de horas de voo referenciado é de 900 horas em 365 dias.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_emergencia,
    'O "sterile cockpit" na decolagem termina em qual altitude?',
    '[{"key":"A","text":"5.000 pés"},{"key":"B","text":"10.000 pés"},{"key":"C","text":"14.000 pés"},{"key":"D","text":"18.000 pés"}]'::jsonb,
    'B', 'O sterile cockpit na decolagem começa na entrega do POB e termina aos 10.000 pés.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_emergencia,
    'Durante uma despressurização, ao atingir 14.000 pés, quais eventos ocorrem automaticamente?',
    '[{"key":"A","text":"Destravamento da porta do cockpit e queda das máscaras de oxigênio"},{"key":"B","text":"Abertura automática de todas as portas"},{"key":"C","text":"Início automático da evacuação"},{"key":"D","text":"Desligamento dos motores"}]'::jsonb,
    'A', 'Aos 14.000 pés, a porta do cockpit se destrava e as máscaras de oxigênio caem automaticamente; as demais alternativas não ocorrem de forma automática nesse estágio.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (
    v_user_id, v_subj_emergencia,
    'Após um pouso de emergência, os técnicos não dão nenhum callout e não respondem ao interfone em emergência. Qual a sequência correta de ações?',
    '[{"key":"A","text":"Iniciar a evacuação imediatamente sem verificar o cockpit"},{"key":"B","text":"Aguardar indefinidamente por instruções"},{"key":"C","text":"Interfonar em emergência; se não atenderem, entrar no cockpit com o código de acesso; se inconscientes, acionar o FIRE PUSH BUTTON e comandar a evacuação"},{"key":"D","text":"Acionar apenas o ELT portátil e aguardar resgate"}]'::jsonb,
    'C', 'A sequência correta é tentar contato via interfone, entrar no cockpit com o código de emergência se não houver resposta e, encontrando os técnicos inconscientes, realizar o FIRE PUSH BUTTON antes de comandar a evacuação.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  raise notice 'Seed concluído: 3 matérias, 5 tags e 15 questões criadas/atualizadas para o usuário %.', v_user_id;
end $$;
