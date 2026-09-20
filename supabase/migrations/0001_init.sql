-- =============================================================================
-- 0001_init.sql
-- Esquema principal do Simulador de Provas.
-- Toda tabela "dona" de dados guarda user_id (= auth.uid()) para permitir RLS
-- simples baseada em posse (ver 0003_rls.sql).
-- =============================================================================

create extension if not exists "pgcrypto"; -- fornece gen_random_uuid()

-- -----------------------------------------------------------------------------
-- profiles: espelha auth.users com dados de perfil próprios da aplicação.
-- É criada automaticamente por um trigger em auth.users (ver 0002).
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- subjects: matérias do usuário (ex.: "Combate a Incêndio").
-- -----------------------------------------------------------------------------
create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  unique (user_id, name)
);

-- -----------------------------------------------------------------------------
-- tags: rótulos livres do usuário (ex.: "cálculo", "legislação"), com cor.
-- -----------------------------------------------------------------------------
create table if not exists public.tags (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  color text not null default '#6366f1',
  created_at timestamptz not null default now(),
  unique (user_id, name)
);

-- -----------------------------------------------------------------------------
-- questions: banco de questões de múltipla escolha.
-- `options` é um array jsonb de { key: "A", text: "..." }.
-- `correct_option` guarda a key (ex.: "A") correspondente à opção correta.
-- -----------------------------------------------------------------------------
create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  subject_id uuid references public.subjects (id) on delete set null,
  statement text not null,
  options jsonb not null,
  correct_option text not null,
  explanation text,
  difficulty text not null default 'media' check (difficulty in ('facil', 'media', 'dificil')),
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- question_tags: relação N:N entre questions e tags.
-- Não possui user_id próprio; a posse é verificada via questions.user_id (RLS).
-- -----------------------------------------------------------------------------
create table if not exists public.question_tags (
  question_id uuid not null references public.questions (id) on delete cascade,
  tag_id uuid not null references public.tags (id) on delete cascade,
  primary key (question_id, tag_id)
);

-- -----------------------------------------------------------------------------
-- exam_sessions: uma "prova" gerada pelo simulador.
-- `question_ids` fixa a lista (e ordem) de questões sorteadas para a sessão,
-- para que /simulado/[sessionId] sempre renderize o mesmo conjunto.
-- -----------------------------------------------------------------------------
create table if not exists public.exam_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  mode text not null check (mode in ('geral', 'materia', 'tag', 'personalizada')),
  subject_id uuid references public.subjects (id) on delete set null,
  tag_id uuid references public.tags (id) on delete set null,
  question_ids uuid[] not null default '{}',
  total_questions integer not null default 0,
  correct_count integer not null default 0,
  score numeric(5, 2) not null default 0,
  started_at timestamptz not null default now(),
  finished_at timestamptz
);

-- -----------------------------------------------------------------------------
-- answers: cada resposta dada dentro de uma exam_session.
-- user_id é denormalizado (repetido de exam_sessions) para simplificar a RLS.
-- -----------------------------------------------------------------------------
create table if not exists public.answers (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.exam_sessions (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  question_id uuid not null references public.questions (id) on delete cascade,
  selected_option text not null,
  is_correct boolean not null,
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- flashcards: gerados a partir de questões erradas ou criados manualmente.
-- Campos de repetição espaçada (repetitions/interval_days/next_review_date)
-- são atualizados pela lógica em lib/sm2 via a action reviewFlashcard.
-- -----------------------------------------------------------------------------
create table if not exists public.flashcards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  question_id uuid references public.questions (id) on delete set null,
  subject_id uuid references public.subjects (id) on delete set null,
  front text not null,
  back text not null,
  status text not null default 'novo' check (status in ('novo', 'revisando', 'dominado')),
  repetitions integer not null default 0,
  interval_days integer not null default 0,
  next_review_date date not null default current_date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- flashcard_reviews: histórico de autoavaliações (errei/difícil/bom/fácil).
-- -----------------------------------------------------------------------------
create table if not exists public.flashcard_reviews (
  id uuid primary key default gen_random_uuid(),
  flashcard_id uuid not null references public.flashcards (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  rating text not null check (rating in ('errei', 'dificil', 'bom', 'facil')),
  reviewed_at timestamptz not null default now()
);
