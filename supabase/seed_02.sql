-- =============================================================================
-- seed_02.sql
-- Segundo lote de questões do material "Resumo de Estudos 32F" (Check
-- Competência - LATAM), cobrindo tópicos não incluídos no seed.sql original:
-- PBEs por modelo, fogo no forno/PED no cockpit, kits médicos (KME/KIM/KPS),
-- ELTs por modelo, sobrevivência no mar, condições clínicas adicionais
-- (convulsão, infarto, diabetes, parto, OVACE, pilot incapacitation),
-- turbulências, passageiros especiais e regulamentação (sobreaviso, diárias).
--
-- Reaproveita as mesmas 6 matérias e 5 tags do seed.sql (idempotente via
-- ON CONFLICT), então pode ser rodado independentemente, antes ou depois
-- do seed.sql original.
--
-- IMPORTANTE: troque o e-mail abaixo pelo usado no cadastro do app.
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
  select id into v_user_id from auth.users where email = 'coxilds@gmail.com' limit 1;

  if v_user_id is null then
    raise exception 'Nenhum usuário encontrado com esse e-mail. Cadastre-se no app em /register e edite o e-mail no topo deste arquivo antes de rodar o seed.';
  end if;

  -- Matérias (reaproveita se já existirem) -----------------------------------
  insert into public.subjects (user_id, name) values (v_user_id, 'Combate ao Fogo')
    on conflict (user_id, name) do update set name = excluded.name returning id into v_subj_fogo;
  insert into public.subjects (user_id, name) values (v_user_id, 'Equipamentos de Emergência')
    on conflict (user_id, name) do update set name = excluded.name returning id into v_subj_equip;
  insert into public.subjects (user_id, name) values (v_user_id, 'Procedimentos de Emergência')
    on conflict (user_id, name) do update set name = excluded.name returning id into v_subj_emerg;
  insert into public.subjects (user_id, name) values (v_user_id, 'Sobrevivência')
    on conflict (user_id, name) do update set name = excluded.name returning id into v_subj_sobrev;
  insert into public.subjects (user_id, name) values (v_user_id, 'Primeiros Socorros')
    on conflict (user_id, name) do update set name = excluded.name returning id into v_subj_socorros;
  insert into public.subjects (user_id, name) values (v_user_id, 'Regulamentação e CRM')
    on conflict (user_id, name) do update set name = excluded.name returning id into v_subj_reg;

  -- Tags (reaproveita se já existirem) ----------------------------------------
  insert into public.tags (user_id, name, color) values (v_user_id, 'cálculo', '#3b82f6')
    on conflict (user_id, name) do update set color = excluded.color returning id into v_tag_calculo;
  insert into public.tags (user_id, name, color) values (v_user_id, 'interpretação', '#8b5cf6')
    on conflict (user_id, name) do update set color = excluded.color returning id into v_tag_interpretacao;
  insert into public.tags (user_id, name, color) values (v_user_id, 'legislação', '#ef4444')
    on conflict (user_id, name) do update set color = excluded.color returning id into v_tag_legislacao;
  insert into public.tags (user_id, name, color) values (v_user_id, 'memorização', '#f59e0b')
    on conflict (user_id, name) do update set color = excluded.color returning id into v_tag_memorizacao;
  insert into public.tags (user_id, name, color) values (v_user_id, 'raciocínio lógico', '#10b981')
    on conflict (user_id, name) do update set color = excluded.color returning id into v_tag_raciocinio;

  -- =========================================================================
  -- COMBATE AO FOGO (complemento)
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'No check pré voo do extintor modelo BCF 1211, na ausência de manômetro, o que deve ser verificado?',
    '[{"key":"A","text":"Apenas o disco full"},{"key":"B","text":"Weight date/validade do peso, e sem ambos, a inspect date dentro de 1 ano"},{"key":"C","text":"A cor do gatilho"},{"key":"D","text":"Nada, o extintor é descartado"}]'::jsonb,
    'B', 'Quando não houver manômetro, o check é feito pela Weight date/validade do peso; sem ambos, verifica-se a inspect date dentro de 01 ano.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Na PBE modelo DRAGER, qual a sequência correta de uso?',
    '[{"key":"A","text":"Aciona primeiro, depois veste"},{"key":"B","text":"Veste primeiro, aciona puxando a bolinha preta na parte inferior, e amarra na cintura"},{"key":"C","text":"Apenas coloca sobre a cabeça sem acionar"},{"key":"D","text":"Puxa o pino lateral antes de vestir"}]'::jsonb,
    'B', 'No modelo DRAGER veste-se primeiro, aciona-se puxando a bolinha preta na parte inferior para baixo, e amarra-se na cintura.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Na PBE modelo AIR LIQUIDE, o que indica que o visor está com problema (NOT OK)?',
    '[{"key":"A","text":"Visor azul"},{"key":"B","text":"Visor vermelho"},{"key":"C","text":"Visor branco"},{"key":"D","text":"Visor amarelo"}]'::jsonb,
    'B', 'No AIR LIQUIDE, o visor em verde indica OK e em vermelho indica NOT OK; o tipo de oxigênio é gasoso.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Em caso de fogo/fumaça no bin, quem deve estar sempre equipado com PBE?',
    '[{"key":"A","text":"Apenas o combatente"},{"key":"B","text":"Apenas o comunicador"},{"key":"C","text":"O combatente e o assistente do combatente"},{"key":"D","text":"Nenhum tripulante, o bin é fechado imediatamente"}]'::jsonb,
    'C', 'Em caso de fogo/fumaça no bin, o combatente e o assistente do combatente SEMPRE devem estar equipados com PBE.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Ao identificar um PED (dispositivo eletrônico) com bateria de lítio superaquecendo (sem fogo), qual a primeira ação?',
    '[{"key":"A","text":"Descarregar o extintor imediatamente"},{"key":"B","text":"Pedir ao passageiro para desligar o equipamento e desconectar da fonte de energia, monitorando até o final do voo"},{"key":"C","text":"Jogar água no equipamento"},{"key":"D","text":"Colocar o equipamento no bin"}]'::jsonb,
    'B', 'Em caso de superaquecimento (sem fogo), pede-se para desligar o equipamento, desconectar da fonte de energia e monitorar até o final do voo.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Em caso de fogo/fumaça dentro do forno, qual é o 1º passo do procedimento?',
    '[{"key":"A","text":"Abrir a porta do forno imediatamente"},{"key":"B","text":"Cortar toda a energia da galley"},{"key":"C","text":"Manter a porta fechada, desligar o forno (power off) e puxar o CB do equipamento"},{"key":"D","text":"Descarregar o extintor pela porta aberta"}]'::jsonb,
    'C', 'O 1º passo é manter a porta fechada (abafamento), desligar o forno e puxar o CB respectivo (isolamento), informando a tripulação técnica e monitorando.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Em um princípio de fogo em bateria de lítio no cockpit, qual o callout que o piloto comunicador transmite via interfone chamando os comissários?',
    '[{"key":"A","text":"Comissário, temos um princípio de fogo em bateria de lítio no cockpit, precisamos de ajuda"},{"key":"B","text":"Comissário Chefe compareça ao cockpit"},{"key":"C","text":"Tripulação, evacuação"},{"key":"D","text":"Comissário, abra a porta imediatamente"}]'::jsonb,
    'A', 'O callout usado é "Comissário, temos um princípio de fogo em bateria de lítio no cockpit, precisamos de ajuda."', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_fogo,
    'Em caso de fogo em um artigo perigoso identificado por um passageiro, qual substância deve-se evitar usar para não espalhar o vazamento?',
    '[{"key":"A","text":"Extintor"},{"key":"B","text":"Água"},{"key":"C","text":"Luvas"},{"key":"D","text":"PBE"}]'::jsonb,
    'B', 'Deve-se evitar o uso de água para não espalhar a substância em caso de vazamento de artigo perigoso.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  -- =========================================================================
  -- EQUIPAMENTOS DE EMERGÊNCIA (complemento)
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Um cilindro de oxigênio portátil com 1 seletor, ajustado no fluxo Hi de 4 litros/min, tem duração aproximada de:',
    '[{"key":"A","text":"30 minutos"},{"key":"B","text":"50 minutos"},{"key":"C","text":"75 minutos"},{"key":"D","text":"150 minutos"}]'::jsonb,
    'C', 'O fluxo Hi de 4 litros/min tem duração de 75 minutos; o fluxo Hi de 2 litros/min dura 150 minutos.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_calculo);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Em um cilindro de oxigênio com 2 saídas, administrando oxigênio a 2 pessoas simultaneamente com fluxo de 6 litros/min, qual a duração aproximada?',
    '[{"key":"A","text":"25 minutos"},{"key":"B","text":"50 minutos"},{"key":"C","text":"75 minutos"},{"key":"D","text":"150 minutos"}]'::jsonb,
    'B', 'Com fluxo de 6 litros/min para 2 pessoas, a duração é de 50 minutos, pois o consumo é mais rápido.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_calculo);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Quantos cilindros de oxigênio portátil estão instalados nas aeronaves A321?',
    '[{"key":"A","text":"3 (três)"},{"key":"B","text":"5 (cinco)"},{"key":"C","text":"7 (sete)"},{"key":"D","text":"9 (nove)"}]'::jsonb,
    'C', 'Estão instalados 05 (cinco) cilindros nas aeronaves A319 e A320, e 07 (sete) nas aeronaves A321.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Um dos cilindros de oxigênio das estações dianteiras, próximas ao cockpit, tem qual particularidade?',
    '[{"key":"A","text":"Não deve ser utilizado, sendo destinado a uma possível assistência aos tripulantes técnicos"},{"key":"B","text":"Tem fluxo reduzido pela metade"},{"key":"C","text":"É exclusivo para bebês"},{"key":"D","text":"Deve ser usado primeiro em qualquer emergência"}]'::jsonb,
    'A', 'Esse cilindro não deve ser utilizado, sendo reservado para uma possível assistência aos tripulantes técnicos.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Qual a capacidade do QTU (tanque de resíduos) e quando ele deve ser esvaziado?',
    '[{"key":"A","text":"100 litros; a cada 2 voos"},{"key":"B","text":"200 litros; sempre ao pousar"},{"key":"C","text":"300 litros; apenas na manutenção"},{"key":"D","text":"200 litros; apenas se estiver cheio"}]'::jsonb,
    'B', 'O QTU tem capacidade para 200 litros e deve sempre ser esvaziado ao pousar.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Para voos de até 2 horas, em qual percentual o QTA (tanque de água) deve estar abastecido, segundo o material de estudo?',
    '[{"key":"A","text":"10%"},{"key":"B","text":"25%"},{"key":"C","text":"50%"},{"key":"D","text":"100%"}]'::jsonb,
    'B', 'Para voos de até 2 horas, o QTA deve estar com 25% do tanque; para voos acima de 2 horas, 50%.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'Na verificação de lanternas com switch OFF/ON na cabine de passageiros, é necessário remover a lanterna do suporte?',
    '[{"key":"A","text":"Sim, é necessário remover para checar o acendimento"},{"key":"B","text":"Não, nunca se remove qualquer lanterna do suporte"},{"key":"C","text":"Apenas nas lanternas comuns"},{"key":"D","text":"Somente durante a manutenção"}]'::jsonb,
    'A', 'Nas lanternas com switch OFF/ON, é necessário remover a lanterna do suporte para verificar o acendimento correto ao colocar o switch em ON.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_equip,
    'As janelas do cockpit, equipadas com scape rope, permitem a evacuação de quantas pessoas em 90 segundos?',
    '[{"key":"A","text":"9 pessoas"},{"key":"B","text":"35 pessoas"},{"key":"C","text":"55 pessoas"},{"key":"D","text":"65 pessoas"}]'::jsonb,
    'A', 'As janelas do cockpit, equipadas com scape rope, permitem a evacuação de 9 pessoas em 90 segundos.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  -- =========================================================================
  -- PROCEDIMENTOS DE EMERGÊNCIA (complemento)
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Durante uma turbulência moderada, qual informação adicional os técnicos passam ao Chefe de Cabine (CF) via interfone, que não é dada na turbulência leve?',
    '[{"key":"A","text":"O tipo de combustível utilizado"},{"key":"B","text":"O tempo previsto de duração da turbulência"},{"key":"C","text":"A altitude de cruzeiro"},{"key":"D","text":"O nome do comandante"}]'::jsonb,
    'B', 'Na turbulência moderada, os técnicos informam via interfone ao CF o tempo previsto de duração.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Durante uma turbulência severa, o que deve ser feito com líquidos quentes que estejam sendo servidos?',
    '[{"key":"A","text":"Continuar o serviço normalmente"},{"key":"B","text":"Colocar dentro dos trolleys, se possível, ou no chão"},{"key":"C","text":"Descartar imediatamente no lixo"},{"key":"D","text":"Entregar rapidamente a todos os passageiros"}]'::jsonb,
    'B', 'Em turbulência severa, os líquidos quentes devem ser colocados dentro dos trolleys, se possível, ou no chão.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Durante uma turbulência severa, é correto que o comissário verifique presencialmente se todos os passageiros estão com o cinto afivelado?',
    '[{"key":"A","text":"Sim, é obrigatório circular pela cabine"},{"key":"B","text":"Não, não se deve tentar verificar presencialmente durante a turbulência severa"},{"key":"C","text":"Apenas nas primeiras fileiras"},{"key":"D","text":"Apenas se solicitado pelo comandante"}]'::jsonb,
    'B', 'Durante turbulência severa, não se deve tentar verificar presencialmente se os passageiros estão sentados com os cintos afivelados.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Se um dos dois pilotos precisar sair do cockpit em voo, e um comissário for solicitado, onde ele deve se sentar?',
    '[{"key":"A","text":"No assento de pilotagem vago"},{"key":"B","text":"Em um dos jump seats do cockpit"},{"key":"C","text":"Em pé, junto à porta"},{"key":"D","text":"Não é permitida a entrada de comissário no cockpit"}]'::jsonb,
    'B', 'O comissário deverá sentar-se em um dos jump seats, nunca nos assentos de pilotagem.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'O Kit UPR (Unruly Passenger Restraint) é utilizado durante a contenção de passageiros indisciplinados de qual categoria?',
    '[{"key":"A","text":"Categoria 1"},{"key":"B","text":"Categoria 2"},{"key":"C","text":"Categoria 3"},{"key":"D","text":"Todas as categorias igualmente"}]'::jsonb,
    'C', 'O Kit UPR substitui o Kit GCI e possui itens utilizados na contenção de passageiros indisciplinados de Categoria 3.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Antes de iniciar o check de cabine para o pouso, com um passageiro indisciplinado de Categoria 3 contido, o que deve ser feito com as tiras adicionais?',
    '[{"key":"A","text":"Devem ser mantidas até o desembarque"},{"key":"B","text":"Devem ser cortadas com a tesoura do Kit UPR/GCI"},{"key":"C","text":"Devem ser substituídas por algemas"},{"key":"D","text":"Não há necessidade de alteração"}]'::jsonb,
    'B', 'Antes de iniciar o check de cabine, deve-se cortar as tiras adicionais com a tesoura do Kit UPR/GCI; o passageiro pousa apenas com as tiras de contenção e o cinto afivelado.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Ao receber uma chamada de emergência do cockpit para a cabine, qual o callout do comandante via interfone?',
    '[{"key":"A","text":"Tripulação, a seus postos"},{"key":"B","text":"Comissário Chefe compareça ao cockpit"},{"key":"C","text":"Tripulação, evacuação"},{"key":"D","text":"Posição de impacto"}]'::jsonb,
    'B', 'O comandante chama o CF em emergência com o callout "Comissário Chefe compareça ao cockpit".', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Em uma emergência preparada, quais informações o comandante passa ao CF quando este entra no cockpit?',
    '[{"key":"A","text":"Apenas o tipo de emergência"},{"key":"B","text":"Tipo, tempo para preparação, local previsto para pouso e quem fará o speech"},{"key":"C","text":"Somente o horário estimado de pouso"},{"key":"D","text":"O nome dos passageiros afetados"}]'::jsonb,
    'B', 'O comandante informa TIPO de emergência, TEMPO para preparação da cabine, LOCAL previsto para pouso e QUEM fará o speech.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Em caso de falha na inflação automática do slide ao abrir uma porta, qual a primeira ação a ser tomada?',
    '[{"key":"A","text":"Bloquear a saída imediatamente"},{"key":"B","text":"Puxar o punho de inflação manual localizado no próprio slide"},{"key":"C","text":"Fechar a porta e tentar novamente"},{"key":"D","text":"Redirecionar todos os passageiros sem tentar inflar"}]'::jsonb,
    'B', 'Em caso de falha na inflação, deve-se puxar o punho de inflação manual; se ainda assim não inflar, bloqueia-se e redireciona-se os passageiros.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_emerg,
    'Caso uma porta fique emperrada durante uma evacuação, qual o procedimento correto?',
    '[{"key":"A","text":"Insistir em abri-la à força"},{"key":"B","text":"Não é necessário bloquear; apenas redirecionar os passageiros para a saída mais próxima"},{"key":"C","text":"Bloquear a saída e aguardar suporte técnico"},{"key":"D","text":"Usar a machadinha para forçar a abertura"}]'::jsonb,
    'B', 'Se a porta ficar emperrada, não é necessário bloquear, pois ninguém conseguirá abri-la; apenas redireciona-se os passageiros para uma saída mais próxima.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);

  -- =========================================================================
  -- SOBREVIVÊNCIA (complemento)
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'O Kit de Sobrevivência Selva possui kit de primeiros socorros em seu conteúdo?',
    '[{"key":"A","text":"Sim, um kit completo"},{"key":"B","text":"Não, o kit de sobrevivência selva NÃO tem kit de primeiros socorros"},{"key":"C","text":"Apenas curativos básicos"},{"key":"D","text":"Somente em aeronaves maritimizadas"}]'::jsonb,
    'B', 'O conteúdo do kit de sobrevivência selva não inclui kit de primeiros socorros.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'Quais são as primeiras medidas a serem tomadas após um pouso de emergência, na ordem correta?',
    '[{"key":"A","text":"Acionar ELT, afastar-se da aeronave, organizar o grupo, fazer triagem"},{"key":"B","text":"Afastar-se a uma distância segura da aeronave, realizar triagem, acionar o ELT portátil e organizar o grupo distribuindo funções"},{"key":"C","text":"Organizar o grupo, acionar ELT, aproximar-se da aeronave, fazer fogueira"},{"key":"D","text":"Fazer fogueira, sinalizar, acionar ELT, afastar-se"}]'::jsonb,
    'B', 'A ordem é: afastar-se a uma distância segura, realizar triagem para primeiros socorros, acionar o ELT portátil e organizar o grupo distribuindo funções.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'O ELT modelo 406 SE possui uma chave seletora com 4 posições. Qual a posição padrão da empresa?',
    '[{"key":"A","text":"XMT"},{"key":"B","text":"OFF"},{"key":"C","text":"ARMED"},{"key":"D","text":"TEST"}]'::jsonb,
    'C', 'Como procedimento padrão da empresa, a chave seletora do ELT 406 SE fica sempre na posição ARMED (aciona ao contato com a água).', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'No ELT modelo Kannad Ultima-S, qual a autonomia máxima do transmissor?',
    '[{"key":"A","text":"24 horas"},{"key":"B","text":"36 horas"},{"key":"C","text":"48 horas"},{"key":"D","text":"72 horas"}]'::jsonb,
    'C', 'O transmissor do modelo Kannad Ultima-S possui autonomia de até 48 horas.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'Ao usar o cartucho pirotécnico para sinalização, em relação ao vento, ele deve ser usado:',
    '[{"key":"A","text":"Contra o vento"},{"key":"B","text":"A favor do vento"},{"key":"C","text":"Perpendicular ao vento"},{"key":"D","text":"A direção do vento é irrelevante"}]'::jsonb,
    'B', 'O cartucho pirotécnico deve ser usado sempre a favor do vento; o lado diurno produz fumaça alaranjada e o noturno, fogo de magnésio.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'Para purificar água na sobrevivência, deve-se utilizar 8 gotas de tintura de iodo (ou 8 pastilhas) por litro, deixando agir por quanto tempo?',
    '[{"key":"A","text":"5 minutos"},{"key":"B","text":"15 minutos"},{"key":"C","text":"30 minutos"},{"key":"D","text":"60 minutos"}]'::jsonb,
    'C', 'Deve-se deixar agir por 30 minutos, ou ferver a água por pelo menos 1 minuto como alternativa.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'No deslocamento na selva, qual a função do "Homem Bússola"?',
    '[{"key":"A","text":"Vai à frente abrindo caminho"},{"key":"B","text":"Marca a distância contando os passos"},{"key":"C","text":"Vai atrás portando a bússola e indicando a direção"},{"key":"D","text":"Carrega o kit de sobrevivência"}]'::jsonb,
    'C', 'O Homem Bússola vai atrás do grupo, portando a bússola e indicando a direção a seguir.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'Em caso de falecimento de um sobrevivente durante uma sobrevivência no mar, o que deve ser feito com o corpo e seus documentos?',
    '[{"key":"A","text":"Manter o corpo e os documentos no bote"},{"key":"B","text":"Recolher os documentos e deixar o corpo afundar no mar"},{"key":"C","text":"Descartar os documentos junto com o corpo"},{"key":"D","text":"Aguardar resgate sem tomar nenhuma ação"}]'::jsonb,
    'B', 'Deve-se recolher os documentos do falecido e deixar o corpo afundar no mar.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'A mooring line que prende o raft à aeronave arrebenta sozinha ao atingir qual pressão aproximada?',
    '[{"key":"A","text":"100 kg"},{"key":"B","text":"250 kg"},{"key":"C","text":"500 kg"},{"key":"D","text":"1000 kg"}]'::jsonb,
    'C', 'A mooring line arrebenta sozinha se atingir pressão de 500kg, mas normalmente deve-se cortá-la após o embarque.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'O pirotécnico do kit de sobrevivência no mar possui quantos disparos, e em qual ângulo deve ser acionado a partir do raft?',
    '[{"key":"A","text":"Um único disparo, a um ângulo de 15 graus"},{"key":"B","text":"Três disparos, na horizontal"},{"key":"C","text":"Disparos ilimitados, a 45 graus"},{"key":"D","text":"Dois disparos, na vertical"}]'::jsonb,
    'A', 'O pirotécnico do kit mar possui um único disparo, devendo ser acionado para fora, a um ângulo de 15 graus.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_sobrev,
    'Quando a aeronave é maritimizada, quantos botes adicionais são disponibilizados e qual a capacidade de cada um?',
    '[{"key":"A","text":"1 bote, capacidade para 55 pessoas"},{"key":"B","text":"2 botes, capacidade para 48 pessoas cada"},{"key":"C","text":"2 botes, capacidade para 100 pessoas cada"},{"key":"D","text":"4 botes, capacidade para 20 pessoas cada"}]'::jsonb,
    'B', 'São disponibilizados 02 botes adicionais nos bins próximos às saídas traseiras (4L e 4R), com capacidade para até 48 pessoas cada.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  -- =========================================================================
  -- PRIMEIROS SOCORROS (complemento)
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Em caso de convulsão, é correto iniciar o atendimento no próprio assento do passageiro?',
    '[{"key":"A","text":"Não, deve-se sempre levar imediatamente para a galley"},{"key":"B","text":"Sim, é a única exceção em que podemos começar o atendimento no próprio assento"},{"key":"C","text":"Apenas se o passageiro estiver consciente"},{"key":"D","text":"Somente com autorização do comandante"}]'::jsonb,
    'B', 'Convulsão é a única exceção em que podemos começar a atender no próprio assento do passageiro.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Ao levar um passageiro em crise convulsiva para o chão da galley, quantos comissários devem realizar o transporte?',
    '[{"key":"A","text":"1 comissário"},{"key":"B","text":"Sempre 2 comissários"},{"key":"C","text":"3 comissários"},{"key":"D","text":"Não deve ser movido em hipótese alguma"}]'::jsonb,
    'B', 'O transporte para o chão da galley deve ser feito sempre por 2 comissários.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Uma dor no peito que dura mais de 30 minutos é classificada como suspeita de:',
    '[{"key":"A","text":"Angina"},{"key":"B","text":"Infarto"},{"key":"C","text":"Refluxo"},{"key":"D","text":"Ansiedade"}]'::jsonb,
    'B', 'Dores que duram mais de 30 minutos sugerem infarto; dores até 10 minutos sugerem angina.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'No atendimento a um suspeito de infarto, o que deve ser feito em relação à alimentação?',
    '[{"key":"A","text":"Oferecer líquidos açucarados"},{"key":"B","text":"Jejum total, não dar alimentos sólidos nem líquidos"},{"key":"C","text":"Oferecer uma refeição leve"},{"key":"D","text":"Apenas água morna"}]'::jsonb,
    'B', 'No caso de suspeita de infarto, deve-se manter jejum total, sem oferecer alimentos sólidos ou líquidos.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Um passageiro diabético apresenta pulso lento, pele pálida e fria e está letárgico. Na dúvida entre hipoglicemia e hiperglicemia, qual a conduta?',
    '[{"key":"A","text":"Aplicar insulina"},{"key":"B","text":"Fornecer líquido açucarado"},{"key":"C","text":"Jejum total"},{"key":"D","text":"Ministrar apenas oxigênio, sem líquidos"}]'::jsonb,
    'B', 'Na dúvida entre hipoglicemia e hiperglicemia, a conduta padrão é fornecer líquido açucarado.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Sinais de agitação, pulso rápido, pele vermelha e quente, sede, boca seca e hálito cetônico indicam:',
    '[{"key":"A","text":"Hipoglicemia"},{"key":"B","text":"Hiperglicemia"},{"key":"C","text":"Choque hipovolêmico"},{"key":"D","text":"Hipotermia"}]'::jsonb,
    'B', 'Esses sinais são característicos de hiperglicemia; a hipoglicemia se apresenta com letargia, pulso lento e pele pálida/fria.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Em um caso de pneumotórax (trauma de tórax aberto), qual tipo de curativo deve ser aplicado?',
    '[{"key":"A","text":"Curativo de 2 pontas"},{"key":"B","text":"Curativo de 3 pontas"},{"key":"C","text":"Curativo de 4 pontas"},{"key":"D","text":"Nenhum curativo, apenas aquecer"}]'::jsonb,
    'B', 'Em caso de pneumotórax, aplica-se o curativo de 3 pontas, além de aquecer e ministrar oxigênio.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Em um trauma abdominal aberto com vísceras expostas, qual o procedimento correto?',
    '[{"key":"A","text":"Recolocar as vísceras no local e fazer curativo compressivo"},{"key":"B","text":"Colocar gaze umedecida sobre as vísceras e cobrir com plástico em curativo de 4 pontas"},{"key":"C","text":"Deixar exposto sem cobrir"},{"key":"D","text":"Cobrir apenas com gaze seca"}]'::jsonb,
    'B', 'Coloca-se gaze umedecida nas vísceras, cobre-se com plástico em curativo de 4 pontas (fechando todos os lados), além de aquecer e ministrar oxigênio.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'No parto a bordo, o clamp do cordão umbilical deve ser posicionado a que distância da barriga do bebê antes de cortar?',
    '[{"key":"A","text":"2 dedos"},{"key":"B","text":"4 dedos"},{"key":"C","text":"8 dedos"},{"key":"D","text":"1 palmo"}]'::jsonb,
    'B', 'Posiciona-se o primeiro clamp a 4 dedos da barriga do bebê, faz-se a "ordenha" e coloca-se outro clamp a mais 4 dedos, cortando entre eles.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Após o parto a bordo, a mãe é levada para a galley com ou sem o bebê?',
    '[{"key":"A","text":"A mãe pousa na galley sem o bebê"},{"key":"B","text":"A mãe e o bebê pousam juntos na galley"},{"key":"C","text":"O bebê fica na galley e a mãe retorna ao assento"},{"key":"D","text":"Ambos retornam ao assento imediatamente"}]'::jsonb,
    'A', 'A mãe pousa na galley sem o bebê, sendo este o único atendimento consciente que levamos para a galley, transportando-a em cadeira de rodas.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Em um engasgo parcial/leve, no qual a vítima ainda consegue tossir, qual a conduta correta?',
    '[{"key":"A","text":"Aplicar imediatamente a Manobra de Heimlich"},{"key":"B","text":"Solicitar que a vítima continue tossindo"},{"key":"C","text":"Dar 5 golpes nas costas imediatamente"},{"key":"D","text":"Iniciar RCP"}]'::jsonb,
    'B', 'No engasgo parcial/leve, com a vítima ainda tossindo, deve-se solicitar que continue tossindo, sem realizar a manobra de desobstrução.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_interpretacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'No procedimento de PILOT INCAPACITATION com o piloto consciente, qual a sequência correta das ações no assento?',
    '[{"key":"A","text":"Cinto, encosto, pés, assento"},{"key":"B","text":"Assento para trás, pés fora do pedal, reclinar o encosto e travar o cinto de inércia com braços cruzados"},{"key":"C","text":"Apenas ministrar oxigênio, sem mexer no assento"},{"key":"D","text":"Reclinar o encosto e sair do cockpit imediatamente"}]'::jsonb,
    'B', 'A sequência é: assento totalmente para trás, retirar os pés do pedal, reclinar o encosto, atar e travar o cinto de inércia com os braços cruzados para dentro, e afrouxar as vestes ministrando oxigênio em EMERGENCY.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_raciocinio);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Em caso de PILOT INCAPACITATION, aciona-se o MedAire em tripulação simples?',
    '[{"key":"A","text":"Sim, sempre"},{"key":"B","text":"Não, não se aciona MedAire em tripulação simples; a comunicação com médico a bordo, se necessário, é via interfone"},{"key":"C","text":"Apenas se houver médico a bordo"},{"key":"D","text":"Apenas em voos internacionais"}]'::jsonb,
    'B', 'Não se aciona MedAire em tripulação simples nesse procedimento; a comunicação com médico a bordo deve ser feita via interfone.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'A Full Face (máscara de oxigênio gasoso do cockpit) pode ser usada em casos de enjoo/vômito ou convulsão?',
    '[{"key":"A","text":"Sim, é indicada nesses casos"},{"key":"B","text":"Nunca deve ser usada em casos de enjoo/vômito ou convulsão"},{"key":"C","text":"Apenas em caso de convulsão"},{"key":"D","text":"Apenas em caso de vômito"}]'::jsonb,
    'B', 'Nunca se deve usar a Full Face em casos de enjoo/vômito ou convulsão, pelo risco de aspiração.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'No lacre do Kit Médico (KME), qual cor indica que o kit já foi utilizado mas ainda contém os elementos mínimos operacionais para prosseguir no voo?',
    '[{"key":"A","text":"Verde"},{"key":"B","text":"Amarelo"},{"key":"C","text":"Vermelho"},{"key":"D","text":"Azul"}]'::jsonb,
    'B', 'O lacre amarelo indica que o kit já foi utilizado, mas contém os elementos mínimos operacionais (EMO) para prosseguir no voo.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Quem pode abrir o Kit Médico (KME) em condições normais?',
    '[{"key":"A","text":"Qualquer comissário de bordo"},{"key":"B","text":"Apenas médico com CRM ou documento de identificação com foto"},{"key":"C","text":"Apenas o comandante"},{"key":"D","text":"Qualquer passageiro voluntário"}]'::jsonb,
    'B', 'O KME só pode ser aberto por médico portando CRM ou documento com foto; enfermeiros e tripulantes podem abrir mediante prévia autorização do MedAire e do comandante.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'O reanimador manual AMBU está localizado em qual kit atualmente, segundo o material de estudo?',
    '[{"key":"A","text":"No KPS/FAK"},{"key":"B","text":"No KIM"},{"key":"C","text":"No KME apenas"},{"key":"D","text":"Não está mais disponível a bordo"}]'::jsonb,
    'B', 'O material informa que não há mais AMBU no KPS, apenas no KIM (Kit Insumos Médicos).', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'O KIM (Kit Insumos Médicos) pode ser aberto por quem?',
    '[{"key":"A","text":"Apenas por médicos"},{"key":"B","text":"Pode ser aberto pela tripulação de cabine"},{"key":"C","text":"Apenas com autorização prévia do comandante"},{"key":"D","text":"Apenas por enfermeiros"}]'::jsonb,
    'B', 'O KIM pode ser aberto pela própria tripulação de cabine, sem necessidade de autorização médica prévia.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'A frequência respiratória normal esperada, por minuto, para um adulto (acima de 8 anos) é de:',
    '[{"key":"A","text":"10 a 15"},{"key":"B","text":"16 a 20"},{"key":"C","text":"20 a 25"},{"key":"D","text":"30 a 40"}]'::jsonb,
    'B', 'A frequência respiratória normal para adultos (+8 anos) é de 16 a 20 respirações por minuto.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_socorros,
    'Um recém-nascido (bebê de 0 a 1 ano) apresenta, normalmente, quantos batimentos cardíacos por minuto?',
    '[{"key":"A","text":"40 a 60"},{"key":"B","text":"60 a 70"},{"key":"C","text":"80 a 180"},{"key":"D","text":"98 a 180"}]'::jsonb,
    'D', 'Bebês (0 a 1 ano) apresentam entre 98 e 180 batimentos por minuto; crianças (1 a 8 anos) entre 80 e 180; adultos entre 60 e 70.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  -- =========================================================================
  -- REGULAMENTAÇÃO E CRM (complemento)
  -- =========================================================================
  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Qual o número máximo de sobreavisos permitidos por mês?',
    '[{"key":"A","text":"4"},{"key":"B","text":"6"},{"key":"C","text":"8"},{"key":"D","text":"10"}]'::jsonb,
    'C', 'O máximo é de 8 sobreavisos mensais, com duração mínima de 3 horas e máxima de 12 horas cada.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'No sobreaviso, quando envolve 2 ou mais aeroportos, qual o tempo de apresentação previsto?',
    '[{"key":"A","text":"1 hora"},{"key":"B","text":"1:30h"},{"key":"C","text":"2:30h"},{"key":"D","text":"4 horas"}]'::jsonb,
    'C', 'Quando o sobreaviso envolve 2 ou mais aeroportos, o tempo de apresentação é de 2:30h (1:30h quando envolve apenas 1 aeroporto).', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Qual o tempo mínimo em solo previsto para o período noturno (22:00h às 04:59h) em escala publicada?',
    '[{"key":"A","text":"1 hora"},{"key":"B","text":"2 horas"},{"key":"C","text":"3 horas"},{"key":"D","text":"4 horas"}]'::jsonb,
    'B', 'O tempo em solo previsto é de 2 horas no período noturno e 3 horas no período diurno (05:00h às 21:59h).', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Sempre que a tripulação simples ultrapassar 10 horas de jornada, qual o acréscimo previsto no repouso?',
    '[{"key":"A","text":"30 minutos"},{"key":"B","text":"1 hora"},{"key":"C","text":"2 horas"},{"key":"D","text":"Não há acréscimo previsto"}]'::jsonb,
    'B', 'Sempre que a tripulação simples ultrapassar 10 horas de jornada, há um acréscimo de 1 hora no repouso.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Segundo a tabela de diárias do material de estudo, o valor da diária de almoço (entre 11:00 e 13:00) é de:',
    '[{"key":"A","text":"R$27,36"},{"key":"B","text":"R$60,00"},{"key":"C","text":"R$109,44"},{"key":"D","text":"R$150,00"}]'::jsonb,
    'C', 'A diária de almoço, entre 11:00 e 13:00, é de R$109,44, o mesmo valor de jantar e ceia.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_memorizacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Considerando as diárias de café/táxi (R$27,36) e almoço (R$109,44) recebidas em um mesmo dia de trabalho, qual o valor total dessas duas diárias somadas?',
    '[{"key":"A","text":"R$109,44"},{"key":"B","text":"R$136,80"},{"key":"C","text":"R$150,00"},{"key":"D","text":"R$218,88"}]'::jsonb,
    'B', 'Somando R$27,36 (café/táxi) + R$109,44 (almoço) = R$136,80.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_calculo);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Crianças menores de 8 anos podem viajar como UMNR (Menor Desacompanhado)?',
    '[{"key":"A","text":"Sim, com autorização especial"},{"key":"B","text":"Não, o serviço não é permitido para menores de 8 anos"},{"key":"C","text":"Sim, apenas em voos diretos"},{"key":"D","text":"Sim, apenas com escolta médica"}]'::jsonb,
    'B', 'Para crianças menores de 8 anos, o serviço de menor desacompanhado (UMNR) não é permitido.', 'facil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Qual o número máximo de UMNR (Menor Desacompanhado) permitido em uma aeronave Narrow Body?',
    '[{"key":"A","text":"1"},{"key":"B","text":"3"},{"key":"C","text":"6"},{"key":"D","text":"Sem limite"}]'::jsonb,
    'B', 'O máximo é de 03 menores desacompanhados em Narrow Body e 06 em Wide Body (acima de 8 anos).', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Segundo o material de estudo, um cachorro ESAN pode ter, no máximo, qual peso para ser aceito a bordo?',
    '[{"key":"A","text":"7 kg"},{"key":"B","text":"12 kg"},{"key":"C","text":"18 kg"},{"key":"D","text":"Sem limite de peso"}]'::jsonb,
    'B', 'São aceitos cães ESAN com peso máximo de 12kg (doze quilos), sendo permitidos no máximo 3 por voo.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'No transporte de CRS (Bebê Conforto), uma criança com menos de 9,1 kg deve ser posicionada de que forma na aeronave?',
    '[{"key":"A","text":"De frente para o nariz da aeronave"},{"key":"B","text":"De costas para o nariz da aeronave"},{"key":"C","text":"De lado, perpendicular ao corredor"},{"key":"D","text":"Sentada normalmente, sem restrição de posição"}]'::jsonb,
    'B', 'Crianças com menos de 9,1kg devem ficar de costas para o nariz da aeronave; acima desse peso, de frente para o nariz.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Uma bagagem inteligente com bateria não removível é proibida quando a bateria exceder qual capacidade?',
    '[{"key":"A","text":"1,5 Wh"},{"key":"B","text":"2,7 Wh"},{"key":"C","text":"5 Wh"},{"key":"D","text":"10 Wh"}]'::jsonb,
    'B', 'Bagagens inteligentes são proibidas quando a bateria não for removível e exceder 2,7 Wh; o transporte é permitido se a bateria for removível e separada da bagagem.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Quantos dias após o nascimento um bebê pode voar, segundo o material de estudo?',
    '[{"key":"A","text":"3 dias"},{"key":"B","text":"5 dias"},{"key":"C","text":"7 dias"},{"key":"D","text":"14 dias"}]'::jsonb,
    'C', 'O bebê só pode voar 7 dias depois do nascimento, e a mãe só pode voar 8 dias após o parto.', 'media'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  insert into public.questions (user_id, subject_id, statement, options, correct_option, explanation, difficulty)
  values (v_user_id, v_subj_reg,
    'Um passageiro DEPA (deportado com escolta) deve viajar com, no mínimo, quantas escoltas?',
    '[{"key":"A","text":"1 escolta"},{"key":"B","text":"2 escoltas"},{"key":"C","text":"3 escoltas"},{"key":"D","text":"Nenhuma escolta é necessária"}]'::jsonb,
    'B', 'Passageiros identificados como DEPA devem viajar com no mínimo 2 escoltas cada, sendo aceitos apenas 2 DEPA por voo.', 'dificil'
  ) returning id into v_q;
  insert into public.question_tags (question_id, tag_id) values (v_q, v_tag_legislacao);

  raise notice 'Seed 02 concluído: complemento de questões do material Check Competência 32F criado/atualizado para o usuário %.', v_user_id;
end $$;
