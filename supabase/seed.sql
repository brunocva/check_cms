-- =============================================================================
-- seed.sql
-- Banco de questões baseado no material "Resumo de Estudos 32F" (Check
-- Competência - LATAM), atualização 06/2026: 6 matérias, 5 tags e ~60
-- questões cobrindo combate a incêndio, equipamentos de emergência,
-- procedimentos de emergência, sobrevivência, primeiros socorros e
-- regulamentação/CRM.
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

  v_subj_fogo uuid;
  v_subj_equip uuid;
  v_subj_emerg uuid;
  v_subj_sobrev uuid;
  v_subj_socorros uuid;
  v_subj_reg uuid;

  v_tag_calculo uuid;
  v_tag_interpretacao uuid;
  v_tag_legislacao uuid;
  v_tag_memorizacao uuid;
  v_tag_raciocinio uuid;

  v_q uuid;
begin
  -- 1) Troque o e-mail abaixo pelo seu e-mail de cadastro no app.
  select id into v_user_id from auth.users where email = 'coxilds@gmail.com' limit 1;

  if v_user_id is null then
    raise exception 'Nenhum usuário encontrado com esse e-mail. Cadastre-se no app em /register e edite o e-mail no topo deste arquivo antes de rodar o seed.';
  end if;

  -- 2) Matérias -------------------------------------------------------------
  insert into public.subjects (user_id, name) values (v_user_id, 'Combate ao Fogo')
    on conflict (user_id, name) do update set name = excluded.name
    returning id into v_subj_fogo;

  insert into public.subjects (user_id, name) values (v_user_id, 'Equipamentos de Emergência')
    on conflict (user_id, name) do update set name = excluded.name
    returning id into v_subj_equip;

  insert into public.subjects (user_id, name) values (v_user_id, 'Procedimentos de Emergência')
    on conflict (user_id, name) do update set name = excluded.name
    returning id into v_subj_emerg;

  insert into public.subjects (user_id, name) values (v_user_id, 'Sobrevivência')
    on conflict (user_id, name) do update set name = excluded.name
    returning id into v_subj_sobrev;

  insert into public.subjects (user_id, name) values (v_user_id, 'Primeiros Socorros')
    on conflict (user_id, name) do update set name = excluded.name
    returning id into v_subj_socorros;

  insert into public.subjects (user_id, name) values (v_user_id, 'Regulamentação e CRM')
    on conflict (user_id, name) do update set name = excluded.name
    returning id into v_subj_reg;

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

  -- =========================================================================
  -- 4) COMBATE AO FOGO
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Ao combater um princípio de fogo com extintor, a que distância da base do fogo o bico ejetor deve ser apontado?',
    '[{"key":"A","text":"0,5 a 1 metro"},{"key":"B","text":"1,5 a 2 metros"},{"key":"C","text":"3 a 4 metros"},{"key":"D","text":"Encostado na chama"}]'::jsonb,
    'B', 'O procedimento padrão indica apontar o bico ejetor para a base do fogo a uma distância de 1,5 a 2 metros, em movimento de varredura.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Todos os extintores da frota A32F têm duração aproximada de descarga de:',
    '[{"key":"A","text":"3 a 5 segundos"},{"key":"B","text":"8 a 10 segundos"},{"key":"C","text":"15 a 20 segundos"},{"key":"D","text":"30 segundos"}]'::jsonb,
    'B', 'Todos os extintores têm duração de 8 a 10 segundos de descarga.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'O extintor do toalete (BCF1301) é acionado automaticamente ao atingir qual temperatura?',
    '[{"key":"A","text":"50°C"},{"key":"B","text":"65°C"},{"key":"C","text":"77°C"},{"key":"D","text":"100°C"}]'::jsonb,
    'C', 'O extintor do toalete é acionado automaticamente ao atingir 77°C.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Quantos extintores portáteis estão instalados na frota A32F?',
    '[{"key":"A","text":"3 (três)"},{"key":"B","text":"5 (cinco)"},{"key":"C","text":"7 (sete)"},{"key":"D","text":"10 (dez)"}]'::jsonb,
    'B', 'São 05 (cinco) extintores portáteis instalados na frota A32F.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'No extintor modelo AIR TOTAL, como é feito o acionamento?',
    '[{"key":"A","text":"Puxando o pino lateral que rompe o lacre amarelo"},{"key":"B","text":"Levantando a trava para liberar o gatilho"},{"key":"C","text":"Rompendo o lacre metálico ao puxar a alavanca preta (menor) de segurança para trás"},{"key":"D","text":"Removendo o pino de segurança da base"}]'::jsonb,
    'C', 'No AIR TOTAL, rompe-se o lacre metálico puxando a alavanca preta (menor) de segurança para trás, e aperta-se o gatilho.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Qual a validade da pesagem e do teste hidrostático dos extintores, respectivamente?',
    '[{"key":"A","text":"12 meses e 5 anos"},{"key":"B","text":"18 meses e 10 anos"},{"key":"C","text":"24 meses e 10 anos"},{"key":"D","text":"18 meses e 5 anos"}]'::jsonb,
    'B', 'A validade da pesagem é de 18 meses e o teste hidrostático de 10 anos.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Qual a validade e a duração de uso das PBEs (Smoke Hoods)?',
    '[{"key":"A","text":"5 anos de validade e 10 minutos de duração"},{"key":"B","text":"10 anos de validade e 15 minutos de duração"},{"key":"C","text":"10 anos de validade e 20 minutos de duração"},{"key":"D","text":"15 anos de validade e 15 minutos de duração"}]'::jsonb,
    'B', 'Todos os modelos de PBE têm validade de 10 anos e duração de 15 minutos.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Na PBE modelo SCOTT, qual a cor do visor esperada no check e qual o tipo de oxigênio?',
    '[{"key":"A","text":"Visor verde; oxigênio gasoso"},{"key":"B","text":"Visor azul ou branca; oxigênio químico"},{"key":"C","text":"Visor amarelo; oxigênio gasoso"},{"key":"D","text":"Visor vermelho; oxigênio químico"}]'::jsonb,
    'B', 'No modelo SCOTT o check inclui visor na cor azul ou branca, e o tipo de oxigênio é químico.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'No sistema de Smoke Detection, o sinal sonoro TRIPLO HI é repetido na cabine de passageiros a cada quantos segundos?',
    '[{"key":"A","text":"10 segundos"},{"key":"B","text":"15 segundos"},{"key":"C","text":"30 segundos"},{"key":"D","text":"60 segundos"}]'::jsonb,
    'C', 'Tocará um TRIPLO HI a cada 30 segundos na cabine de passageiros enquanto o smoke detection estiver ativo.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Um fogo em óleo, álcool ou gasolina, que queima na superfície e não pode ser extinto com água, é classificado como:',
    '[{"key":"A","text":"Classe A"},{"key":"B","text":"Classe B"},{"key":"C","text":"Classe C"},{"key":"D","text":"Classe D"}]'::jsonb,
    'B', 'A Classe B corresponde a líquidos inflamáveis (óleo, álcool, solvente, gasolina), que não podem ser extintos com água.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'No método de extinção de fogo por "abafamento", o que está sendo retirado da reação de combustão?',
    '[{"key":"A","text":"O calor"},{"key":"B","text":"O combustível"},{"key":"C","text":"O comburente (oxigênio)"},{"key":"D","text":"A reação em cadeia"}]'::jsonb,
    'C', 'O abafamento consiste em retirar o comburente (oxigênio) da reação de combustão.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'No procedimento base de combate ao fogo, qual tripulante é responsável por manter comunicação constante com a tripulação técnica e informar localização, cheiro, cor e progresso do combate?',
    '[{"key":"A","text":"1º Combatente"},{"key":"B","text":"2º Comunicador"},{"key":"C","text":"3º Assistente do combatente"},{"key":"D","text":"4º Suporte"}]'::jsonb,
    'B', 'O 2º Comunicador notifica a tripulação técnica, mantém comunicação constante e repassa as informações do cockpit para a cabine.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Em caso de fogo em um lavatório com a porta quente, como o extintor deve ser descarregado?',
    '[{"key":"A","text":"Em movimento horizontal, de um lado para o outro"},{"key":"B","text":"Em movimento vertical de cima para baixo, por uma pequena fresta da porta"},{"key":"C","text":"Abrindo a porta totalmente antes de disparar"},{"key":"D","text":"Não se deve usar extintor em porta quente"}]'::jsonb,
    'B', 'Com a porta quente, usa-se a porta como escudo, abre-se uma pequena fresta suficiente para passar o bico do extintor e descarrega-se em movimento vertical de cima a baixo.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Em caso de fogo em bateria de lítio, qual item NUNCA deve ser utilizado para resfriar o equipamento?',
    '[{"key":"A","text":"Água"},{"key":"B","text":"Gelo"},{"key":"C","text":"Extintor"},{"key":"D","text":"Lixeira do lavatório"}]'::jsonb,
    'B', 'Nunca se deve utilizar gelo no procedimento para resfriar o equipamento com bateria de lítio.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Qual o código de acesso de emergência ao cockpit (KEY PED)?',
    '[{"key":"A","text":"0000#"},{"key":"B","text":"0763#"},{"key":"C","text":"1234#"},{"key":"D","text":"7630#"}]'::jsonb,
    'B', 'O código de acesso em emergência ao cockpit é 0763#, e a porta destrava por 5 segundos após 30 segundos de espera.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  -- =========================================================================
  -- 5) EQUIPAMENTOS DE EMERGÊNCIA
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Quantas máscaras de oxigênio gasoso modelo FULL FACE existem no cockpit, e qual a capacidade do cilindro que as alimenta?',
    '[{"key":"A","text":"2 máscaras, cilindro de 1200 litros"},{"key":"B","text":"4 máscaras, cilindro de 2200 litros"},{"key":"C","text":"4 máscaras, cilindro de 1500 litros"},{"key":"D","text":"6 máscaras, cilindro de 2200 litros"}]'::jsonb,
    'B', 'No cockpit há 4 máscaras FULL FACE, alimentadas por um cilindro de 2200 litros no compartimento de aviônicos.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Na máscara FULL FACE, a posição 100% tem qual função?',
    '[{"key":"A","text":"Mistura o oxigênio com o ar da cabine"},{"key":"B","text":"Libera oxigênio puro, sem misturar com o ar da cabine"},{"key":"C","text":"Desliga o fluxo de oxigênio"},{"key":"D","text":"Ativa o fluxo contínuo terapêutico"}]'::jsonb,
    'B', 'A posição 100% libera oxigênio puro sem mistura com o ar da cabine, e é usada na presença de fumaça ou gases tóxicos.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Qual a duração aproximada do sistema fixo de oxigênio químico das máscaras da cabine de passageiros?',
    '[{"key":"A","text":"5 a 10 minutos"},{"key":"B","text":"15 a 22 minutos"},{"key":"C","text":"30 a 40 minutos"},{"key":"D","text":"60 minutos"}]'::jsonb,
    'B', 'O sistema fixo de oxigênio produz oxigênio químico com duração de 15 a 22 minutos.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Quantas máscaras de oxigênio existem em cada PSU (Passenger Service Unit)?',
    '[{"key":"A","text":"2 máscaras"},{"key":"B","text":"3 máscaras"},{"key":"C","text":"4 máscaras"},{"key":"D","text":"5 máscaras"}]'::jsonb,
    'C', 'Os PSUs possuem 4 máscaras de oxigênio químico; os ASUs possuem 2 e os LSUs possuem 2 (oxigênio gasoso).', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'A machadinha, quando usada para cortar fios elétricos energizados, isola voltagens de até quanto?',
    '[{"key":"A","text":"1.500 volts"},{"key":"B","text":"5.000 volts"},{"key":"C","text":"15.000 volts"},{"key":"D","text":"50.000 volts"}]'::jsonb,
    'C', 'A proteção do cabo da machadinha isola voltagens de até 15.000 volts.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'As luzes de emergência (EPSU) duram quanto tempo enquanto conectadas ao avião?',
    '[{"key":"A","text":"8 minutos"},{"key":"B","text":"10 minutos"},{"key":"C","text":"12 minutos"},{"key":"D","text":"15 minutos"}]'::jsonb,
    'C', 'As EPSUs duram 12 minutos enquanto conectadas ao avião; desconectadas em amaragem, 2 lâmpadas específicas duram de 8 a 12hs.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Em uma lanterna com bateria não recarregável, a luz vermelha piscando a cada dez segundos indica:',
    '[{"key":"A","text":"Bateria funcionando normalmente"},{"key":"B","text":"Que a bateria está no fim de sua vida útil"},{"key":"C","text":"Que a lanterna está desligada"},{"key":"D","text":"Erro de fabricação"}]'::jsonb,
    'B', 'Quando a bateria estiver no fim de sua vida útil, a luz vermelha piscará a cada dez segundos.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Uma porta tipo C, equipada com escape slide de pista simples, tem capacidade de evacuar quantas pessoas em 90 segundos?',
    '[{"key":"A","text":"35 pessoas"},{"key":"B","text":"55 pessoas"},{"key":"C","text":"65 pessoas"},{"key":"D","text":"9 pessoas"}]'::jsonb,
    'B', 'Portas tipo C evacuam 55 pessoas em 90 segundos; as portas tipo C+ (A321neo) evacuam 65 pessoas.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'O código de acesso de emergência do KEY PED pode ficar inoperante por, no máximo, quantos dias?',
    '[{"key":"A","text":"3 dias"},{"key":"B","text":"5 dias"},{"key":"C","text":"7 dias"},{"key":"D","text":"10 dias"}]'::jsonb,
    'C', 'Podemos voar com o KEY PED inoperante por até 7 dias.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'O manômetro de pressão de um cilindro de oxigênio portátil deve estar indicado em qual faixa?',
    '[{"key":"A","text":"Entre 500 e 1000 PSI"},{"key":"B","text":"Entre 1000 e 2000 PSI"},{"key":"C","text":"Entre 2000 e 3000 PSI"},{"key":"D","text":"Acima de 3000 PSI"}]'::jsonb,
    'B', 'O manômetro de pressão do cilindro de oxigênio portátil deve estar indicado entre 1000 e 2000 PSI.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  -- =========================================================================
  -- 6) PROCEDIMENTOS DE EMERGÊNCIA
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'O sterile cockpit na decolagem começa na entrega do POB e termina em qual altitude?',
    '[{"key":"A","text":"5.000 pés"},{"key":"B","text":"10.000 pés"},{"key":"C","text":"14.000 pés"},{"key":"D","text":"18.000 pés"}]'::jsonb,
    'B', 'O sterile cockpit na decolagem termina aos 10.000 pés (tripulação dez mil pés).', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Durante uma despressurização, ao atingir 14.000 pés, quais eventos ocorrem automaticamente?',
    '[{"key":"A","text":"Destravamento da porta do cockpit e queda das máscaras de oxigênio"},{"key":"B","text":"Abertura automática de todas as portas"},{"key":"C","text":"Início automático da evacuação"},{"key":"D","text":"Desligamento dos motores"}]'::jsonb,
    'A', 'Aos 14.000 pés a porta do cockpit se destrava e as máscaras de oxigênio caem automaticamente.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'As ações pós despressurização (Walk Around Procedure) começam quando:',
    '[{"key":"A","text":"A aeronave atinge 20.000 pés"},{"key":"B","text":"A aeronave cruza 10.000ft e o sinal de atar cintos é desligado"},{"key":"C","text":"O comandante chama o CF ao cockpit"},{"key":"D","text":"As máscaras de oxigênio se recolhem automaticamente"}]'::jsonb,
    'B', 'As ações pós despressurização se iniciam simultaneamente após o callout "altitude segura", quando a aeronave cruza 10.000ft e o sinal de atar cintos é desligado.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'São consideradas situações de evacuação eminente, EXCETO:',
    '[{"key":"A","text":"Fogo/fumaça densa"},{"key":"B","text":"Amaragem"},{"key":"C","text":"Grande ruptura da fuselagem"},{"key":"D","text":"Turbulência moderada"}]'::jsonb,
    'D', 'Fogo/fumaça densa, amaragem e grande ruptura da fuselagem são sinais de evacuação eminente; turbulência moderada não o é.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'O procedimento de FIRE PUSH BUTTON, realizado após um pouso de emergência sem resposta dos técnicos, corta quais sistemas?',
    '[{"key":"A","text":"Apenas o combustível"},{"key":"B","text":"Combustível, elétrica, hidráulica e pneumática"},{"key":"C","text":"Apenas a energia elétrica da galley"},{"key":"D","text":"Apenas o sistema de comunicação"}]'::jsonb,
    'B', 'O procedimento de FIRE PUSH BUTTON corta o combustível, a elétrica, a hidráulica e a pneumática dos motores.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Aos 500 pés, próximo a um pouso de emergência preparado, qual callout a tripulação técnica repete duas vezes?',
    '[{"key":"A","text":"Tripulação, a seus postos!"},{"key":"B","text":"Posição de impacto!"},{"key":"C","text":"Tripulação, evacuação!"},{"key":"D","text":"Permaneçam sentados!"}]'::jsonb,
    'B', 'Aos 500ft o callout "Posição de impacto! / Brace!" é repetido 2 vezes em português e inglês.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Após um pouso de emergência, os técnicos não dão nenhum callout e não respondem ao interfone em emergência. Qual a sequência correta de ações?',
    '[{"key":"A","text":"Iniciar a evacuação imediatamente sem verificar o cockpit"},{"key":"B","text":"Aguardar indefinidamente por instruções"},{"key":"C","text":"Interfonar em emergência; se não atenderem, entrar no cockpit com o código de acesso; se inconscientes, acionar o FIRE PUSH BUTTON e comandar a evacuação"},{"key":"D","text":"Acionar apenas o ELT portátil e aguardar resgate"}]'::jsonb,
    'C', 'A sequência correta é interfonar em emergência, entrar no cockpit com o código 0763# se não houver resposta e, encontrando os técnicos inconscientes, realizar o FIRE PUSH BUTTON antes de comandar a evacuação.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Em uma amaragem no A321, como as portas 2L/2R e 3L/3R devem estar configuradas em uma emergência preparada?',
    '[{"key":"A","text":"Com os slides armados"},{"key":"B","text":"Com os slides desarmados"},{"key":"C","text":"Travadas e inutilizáveis"},{"key":"D","text":"Abertas em automático desde a preparação"}]'::jsonb,
    'B', 'Nas aeronaves A321, em emergência preparada, as portas 2L/2R e 3L/3R estão com os slides desarmados.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'A voz de comando "VISTAM SEUS COLETES!" (PUT ON LIFEVESTS) é utilizada em qual situação?',
    '[{"key":"A","text":"Pouso em terra preparado"},{"key":"B","text":"Pouso na água em emergência não preparada"},{"key":"C","text":"Turbulência severa"},{"key":"D","text":"Passageiro indisciplinado"}]'::jsonb,
    'B', '"Vistam seus coletes!" é uma voz de comando usada no pouso na água em emergência não preparada.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Um passageiro cujo comportamento é agressivo e violento, incluindo agressões físicas e ameaças, é classificado em qual categoria de passageiro indisciplinado?',
    '[{"key":"A","text":"Categoria 1"},{"key":"B","text":"Categoria 2"},{"key":"C","text":"Categoria 3"},{"key":"D","text":"Não há categorização"}]'::jsonb,
    'C', 'A Categoria 3 corresponde a comportamento agressivo e violento, com contenção como procedimento.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Em caso de ameaça de bomba a bordo em nível vermelho, ainda em solo, o que os passageiros devem fazer com seus pertences?',
    '[{"key":"A","text":"Deixar todos os pertences a bordo"},{"key":"B","text":"Levar todos os seus pertences"},{"key":"C","text":"Levar apenas documentos"},{"key":"D","text":"Levar apenas bagagem de mão pequena"}]'::jsonb,
    'B', 'Em ameaça de bomba nível vermelho ainda em solo, com desembarque normal, todos devem levar todos os seus pertences.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Ao desembarcar após o pouso, por qual lado da aeronave todos os passageiros devem sair (com exceção da porta 4L)?',
    '[{"key":"A","text":"Lado Lima"},{"key":"B","text":"Lado Romeo"},{"key":"C","text":"Ambos os lados igualmente"},{"key":"D","text":"Pelo lado com o objeto suspeito"}]'::jsonb,
    'A', 'Após o pouso, na evacuação relacionada a ameaça de bomba, todos devem sair pelo lado LIMA da aeronave, com exceção da 4L.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  -- =========================================================================
  -- 7) SOBREVIVÊNCIA
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'Quantos kits de sobrevivência selva existem nas aeronaves A319/A320/A321?',
    '[{"key":"A","text":"1 (um)"},{"key":"B","text":"2 (dois)"},{"key":"C","text":"3 (três)"},{"key":"D","text":"4 (quatro)"}]'::jsonb,
    'B', 'Nas aeronaves A319/A320/A321 haverá 02 (dois) kits de Sobrevivência Selva.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'Por quanto tempo em média o ELT portátil transmite sinal, e qual seu raio de precisão?',
    '[{"key":"A","text":"24 horas / 1 a 2 km"},{"key":"B","text":"48 horas / 2 a 5 km"},{"key":"C","text":"72 horas / 5 a 10 km"},{"key":"D","text":"12 horas / 1 km"}]'::jsonb,
    'B', 'O ELT portátil transmite sinal em média por 48 horas, com raio de precisão de 2 a 5km.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'O ELT modelo 406, ao entrar em contato com água salgada, aciona em quanto tempo?',
    '[{"key":"A","text":"1 segundo"},{"key":"B","text":"5 segundos"},{"key":"C","text":"30 segundos"},{"key":"D","text":"5 minutos"}]'::jsonb,
    'B', 'O modelo 406 aciona em 5 segundos na água salgada, ou 5 minutos na água doce.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'A mnemônica SAFADA, usada após o pouso de emergência para organizar prioridades de sobrevivência, representa:',
    '[{"key":"A","text":"Segurança, Água, Fogo, Alimento, Descanso, Abrigo"},{"key":"B","text":"Sinalização, Abrigo, Fogo, Água, Descanso, Alimento"},{"key":"C","text":"Sobrevivência, Ajuda, Fogo, Água, Direção, Alimento"},{"key":"D","text":"Segurança, Abrigo, Fuga, Água, Descanso, Alimento"}]'::jsonb,
    'B', 'SAFADA significa Sinalização, Abrigo, Fogo, Água, Descanso e Alimento (em amaragem: SAADA).', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'Qual a quantidade mínima de água necessária por dia para sobrevivência na selva, mar e gelo?',
    '[{"key":"A","text":"250 ml"},{"key":"B","text":"500 ml"},{"key":"C","text":"1 litro"},{"key":"D","text":"1,5 litro"}]'::jsonb,
    'B', 'A quantidade mínima é de 500ml por dia na selva, mar e gelo (no deserto é 1,5L).', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'Caso o grupo de sobreviventes realize deslocamento na selva em busca de ajuda, qual o número máximo de pessoas permitido no grupo?',
    '[{"key":"A","text":"2 pessoas"},{"key":"B","text":"3 pessoas"},{"key":"C","text":"4 pessoas"},{"key":"D","text":"6 pessoas"}]'::jsonb,
    'C', 'O grupo de deslocamento na selva não poderá ser maior que 4 pessoas.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'A iluminação do colete salva-vidas, acionada por bateria em contato com a água, tem duração de:',
    '[{"key":"A","text":"2 a 4 horas"},{"key":"B","text":"4 a 6 horas"},{"key":"C","text":"8 a 12 horas"},{"key":"D","text":"24 horas"}]'::jsonb,
    'C', 'A iluminação do colete salva-vidas tem duração de 8 a 12 horas.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'Cada slide raft tem capacidade para quantas pessoas?',
    '[{"key":"A","text":"35 pessoas"},{"key":"B","text":"48 pessoas"},{"key":"C","text":"55 pessoas"},{"key":"D","text":"65 pessoas"}]'::jsonb,
    'C', 'Cada slide raft tem capacidade para 55 pessoas; com botes adicionais, a capacidade adicional é de 48 pessoas.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'Nas primeiras 24 horas após o pouso de emergência, o racionamento de alimentos deve ser feito da seguinte forma:',
    '[{"key":"A","text":"Distribuição normal de alimentos"},{"key":"B","text":"Jejum total, exceto para crianças e feridos"},{"key":"C","text":"Somente alimentos de origem animal"},{"key":"D","text":"Ração dobrada para recuperar energia"}]'::jsonb,
    'B', 'Nas primeiras 24 horas deve-se manter jejum total, com exceção de crianças e feridos.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  -- =========================================================================
  -- 8) PRIMEIROS SOCORROS
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Qual a relação compressões:ventilações na RCP em adolescentes e adultos (acima de 8 anos)?',
    '[{"key":"A","text":"15:2"},{"key":"B","text":"30:2"},{"key":"C","text":"5:1"},{"key":"D","text":"10:2"}]'::jsonb,
    'B', 'Para adolescentes e adultos, o ciclo padrão é de 5 ciclos de 30 compressões para 2 ventilações.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Qual a profundidade recomendada para compressões torácicas em um adulto durante a RCP?',
    '[{"key":"A","text":"1 a 2 cm"},{"key":"B","text":"Mínimo de 5 cm, não excedendo 6 cm"},{"key":"C","text":"Exatos 10 cm"},{"key":"D","text":"Não há profundidade definida"}]'::jsonb,
    'B', 'As compressões em adultos devem ter profundidade mínima de 5 cm, sem exceder 6 cm.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Na RCP neonatal (0 a 28 dias), qual o ciclo de compressões e ventilações?',
    '[{"key":"A","text":"30 compressões, 2 ventilações"},{"key":"B","text":"15 compressões, 2 ventilações"},{"key":"C","text":"10 compressões, 1 ventilação"},{"key":"D","text":"5 compressões, 1 ventilação"}]'::jsonb,
    'B', 'A RCP neonatal utiliza 10 ciclos de 15 compressões e 2 ventilações, com profundidade de 4 cm.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Trabalhando na frequência recomendada de 100 a 120 compressões por minuto na RCP de adultos, aproximadamente quantos ciclos completos de 30 compressões cabem em 1 minuto?',
    '[{"key":"A","text":"Entre 1 e 2 ciclos"},{"key":"B","text":"Entre 3 e 4 ciclos"},{"key":"C","text":"Entre 6 e 7 ciclos"},{"key":"D","text":"10 ciclos"}]'::jsonb,
    'B', 'Dividindo 100–120 compressões por 30 (compressões por ciclo) chegamos a aproximadamente 3 a 4 ciclos por minuto.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_calculo);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Na escala de Cincinnati (avaliação de AVC/AVE), quais três sinais são observados?',
    '[{"key":"A","text":"Febre, tosse e falta de ar"},{"key":"B","text":"Face, força e fala"},{"key":"C","text":"Pulso, pressão e pele"},{"key":"D","text":"Visão, audição e equilíbrio"}]'::jsonb,
    'B', 'A escala avalia assimetria facial, força motora (queda de braço) e alteração de fala — mnemônico "Face, força e fala" (FFF).', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Uma vítima apresenta pulso rápido e fino, pele pálida, fria e úmida, e queda no nível de consciência. Qual quadro é mais provável?',
    '[{"key":"A","text":"Convulsão"},{"key":"B","text":"Choque hipovolêmico"},{"key":"C","text":"Hiperglicemia"},{"key":"D","text":"Enjoo comum"}]'::jsonb,
    'B', 'Pulso rápido e fino, pele pálida/fria/úmida e alteração de consciência são sinais clássicos de choque hipovolêmico.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'O que significa a sigla SECOPA, usada na avaliação primária de uma vítima?',
    '[{"key":"A","text":"Segurança, Consciência, Pupila"},{"key":"B","text":"Segurança do local, Comprovar a consciência, Pedir ajuda"},{"key":"C","text":"Sinal, Comunicação, Posicionamento"},{"key":"D","text":"Socorro, Cuidado, Precaução"}]'::jsonb,
    'B', 'SECOPA = Segurança do local, Comprovar a consciência (TO-RES-MO) e Pedir ajuda.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Na avaliação secundária AMPLA, a letra "M" representa qual item?',
    '[{"key":"A","text":"Medicamentos"},{"key":"B","text":"Movimento"},{"key":"C","text":"Mental"},{"key":"D","text":"Massagem"}]'::jsonb,
    'A', 'AMPLA = Alergias, Medicamentos, Problemas de saúde/passado médico, Líquidos e alimentos, Associação ao evento.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Quantas situações são previstas em que se pode interromper a RCP?',
    '[{"key":"A","text":"3"},{"key":"B","text":"4"},{"key":"C","text":"5"},{"key":"D","text":"6"}]'::jsonb,
    'C', 'São 5 situações: leitura de choque do DEA, retorno de circulação espontânea, segurança comprometida, óbito relatado por médico e assunção da ocorrência por médicos em solo.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'O DEA modelo CARD AID pode ser usado em crianças a partir de qual idade e peso mínimo?',
    '[{"key":"A","text":"Acima de 1 ano e peso acima de 20kg"},{"key":"B","text":"Acima de 6 meses e qualquer peso"},{"key":"C","text":"Acima de 8 anos e peso acima de 25kg"},{"key":"D","text":"Não é indicado para crianças"}]'::jsonb,
    'A', 'O DEA Card Aid pode ser usado em crianças acima de 1 ano, somente se o peso for acima de 20kg.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Na Manobra de Heimlich para adultos com engasgo total, quantos golpes nas costas e compressões abdominais devem ser aplicados em cada ciclo?',
    '[{"key":"A","text":"3 golpes e 3 compressões"},{"key":"B","text":"5 golpes e 5 compressões"},{"key":"C","text":"10 golpes e 10 compressões"},{"key":"D","text":"Apenas compressões, sem golpes"}]'::jsonb,
    'B', 'Devem ser dados 5 golpes nas costas seguidos de 5 compressões abdominais.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Um choque hipovolêmico é consequência de uma hemorragia com perda de sangue igual ou superior a:',
    '[{"key":"A","text":"5%"},{"key":"B","text":"10%"},{"key":"C","text":"20%"},{"key":"D","text":"50%"}]'::jsonb,
    'C', 'O choque hipovolêmico é consequência de hemorragia com perda de sangue igual ou superior a 20%.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Uma queimadura com dor, vermelhidão, bolhas e inchaço, sem atingir camadas profundas da pele, é classificada como:',
    '[{"key":"A","text":"1º grau"},{"key":"B","text":"2º grau"},{"key":"C","text":"3º grau"},{"key":"D","text":"Queimadura química"}]'::jsonb,
    'B', 'A queimadura de 2º grau apresenta dor, vermelhidão, bolhas e inchaço.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Ao aplicar um torniquete em um sangramento do cotovelo para baixo, a que distância da axila ele deve ser posicionado?',
    '[{"key":"A","text":"Cerca de 5 cm"},{"key":"B","text":"Cerca de 10 cm (o espaço da palma de uma mão)"},{"key":"C","text":"Cerca de 20 cm"},{"key":"D","text":"Diretamente sobre o ferimento"}]'::jsonb,
    'B', 'Deve-se medir o espaço da palma de uma mão (cerca de 10 cm) a partir da axila para posicionar o torniquete.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_calculo);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Na triagem de múltiplas vítimas, uma vítima com frequência respiratória maior que 30/min, enchimento capilar maior que 2 segundos e que não responde a comandos simples é classificada como prioridade:',
    '[{"key":"A","text":"1 - Vermelho"},{"key":"B","text":"2 - Amarelo"},{"key":"C","text":"3 - Verde"},{"key":"D","text":"4 - Preto"}]'::jsonb,
    'A', 'Qualquer alteração nos critérios de respiração, perfusão ou estado mental classifica a vítima como prioridade 1 (vermelha).', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  -- =========================================================================
  -- 9) REGULAMENTAÇÃO E CRM
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'A Lei do Aeronauta é regulamentada por qual número de lei?',
    '[{"key":"A","text":"Lei 13.475/2017"},{"key":"B","text":"Lei 12.345/2015"},{"key":"C","text":"Lei 8.078/1990"},{"key":"D","text":"Lei 14.133/2021"}]'::jsonb,
    'A', 'A Lei do Aeronauta é a Lei 13.475/2017.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Qual o limite de horas mensais de voo (NB) previsto na Lei do Aeronauta?',
    '[{"key":"A","text":"60 horas"},{"key":"B","text":"90 horas em 28 dias"},{"key":"C","text":"120 horas"},{"key":"D","text":"176 horas"}]'::jsonb,
    'B', 'O limite mensal de horas de voo é de 90 horas em 28 dias.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Qual o limite máximo de horas anuais de voo previsto?',
    '[{"key":"A","text":"600 horas"},{"key":"B","text":"750 horas"},{"key":"C","text":"900 horas em 365 dias"},{"key":"D","text":"1000 horas"}]'::jsonb,
    'C', 'O limite anual de horas de voo é de 900 horas em 365 dias.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Qual a jornada semanal máxima permitida para o tripulante NB?',
    '[{"key":"A","text":"40 horas"},{"key":"B","text":"44 horas"},{"key":"C","text":"48 horas"},{"key":"D","text":"50 horas"}]'::jsonb,
    'B', 'A jornada semanal máxima do tripulante NB é de 44 horas.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Com que frequência mínima o tripulante tem direito à monofolga?',
    '[{"key":"A","text":"1 a cada 15 dias"},{"key":"B","text":"1 a cada 30 dias"},{"key":"C","text":"1 a cada 45 dias"},{"key":"D","text":"1 a cada 60 dias"}]'::jsonb,
    'B', 'A monofolga é garantida 1 a cada 30 dias (ou 3 em caso de período oposto).', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Qual o número máximo de madrugadas consecutivas permitido, salvo exceção prevista em norma?',
    '[{"key":"A","text":"1 madrugada"},{"key":"B","text":"2 madrugadas"},{"key":"C","text":"3 madrugadas"},{"key":"D","text":"4 madrugadas"}]'::jsonb,
    'B', 'O máximo é de 2 madrugadas consecutivas e 4 totais num período de 7 dias (168 horas), com exceção prevista para uma 3ª consecutiva em condições específicas.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Considerando a tabela de repouso, qual o tempo de repouso mínimo para um tripulante que finaliza a jornada fora da base e reinicia também fora da base?',
    '[{"key":"A","text":"12 horas"},{"key":"B","text":"14 horas"},{"key":"C","text":"16 horas"},{"key":"D","text":"18 horas"}]'::jsonb,
    'C', 'Fim fora / início fora exige 16 horas de repouso, o maior intervalo da tabela.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Quantos são os pilares do CRM (Crew Resource Management) citados no material de estudo?',
    '[{"key":"A","text":"5 pilares"},{"key":"B","text":"7 pilares"},{"key":"C","text":"9 pilares"},{"key":"D","text":"12 pilares"}]'::jsonb,
    'C', 'São 9 pilares: conhecimento, comunicação, liderança/trabalho em equipe/carga de trabalho, consciência situacional, planejamento/tomada de decisão, automatismo e tecnologia, autoavaliação, monitoramento, e aderência a procedimentos.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'De acordo com a Resolução 461, quantos passageiros sob custódia, no máximo, a LATAM Brasil pode transportar em um mesmo voo?',
    '[{"key":"A","text":"1"},{"key":"B","text":"2"},{"key":"C","text":"3"},{"key":"D","text":"5"}]'::jsonb,
    'B', 'A LATAM Brasil não pode transportar mais do que 02 (dois) passageiros custodiados em um mesmo voo, cada um com no mínimo 2 escoltas.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Uma gestante pode voar até quantas semanas de gestação, segundo o material de estudo?',
    '[{"key":"A","text":"32 semanas"},{"key":"B","text":"36 semanas"},{"key":"C","text":"39 semanas"},{"key":"D","text":"40 semanas"}]'::jsonb,
    'C', 'Acima de 39 semanas não é permitido voar.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  raise notice 'Seed concluído: 6 matérias, 5 tags e questões do material Check Competência 32F criadas/atualizadas para o usuário %.', v_user_id;
end $$;
