-- =============================================================================
-- 0003_rls.sql
-- Row Level Security: cada usuário só enxerga e altera os próprios dados.
--
-- Estratégia: uma única policy "for all" por tabela, com `using` (para
-- select/update/delete) e `with check` (para insert/update) exigindo
-- auth.uid() = user_id. Tabelas sem user_id próprio (question_tags) verificam
-- a posse via EXISTS na tabela pai.
-- =============================================================================

-- profiles ---------------------------------------------------------------
alter table public.profiles enable row level security;

create policy "profiles_owner"
  on public.profiles
  for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- subjects -----------------------------------------------------------------
alter table public.subjects enable row level security;

create policy "subjects_owner"
  on public.subjects
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- tags -----------------------------------------------------------------------
alter table public.tags enable row level security;

create policy "tags_owner"
  on public.tags
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- questions --------------------------------------------------------------
alter table public.questions enable row level security;

create policy "questions_owner"
  on public.questions
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- question_tags (posse verificada via questions) --------------------------
alter table public.question_tags enable row level security;

create policy "question_tags_owner"
  on public.question_tags
  for all
  using (
    exists (
      select 1 from public.questions q
      where q.id = question_tags.question_id
        and q.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.questions q
      where q.id = question_tags.question_id
        and q.user_id = auth.uid()
    )
  );

-- exam_sessions ------------------------------------------------------------
alter table public.exam_sessions enable row level security;

create policy "exam_sessions_owner"
  on public.exam_sessions
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- answers --------------------------------------------------------------------
alter table public.answers enable row level security;

create policy "answers_owner"
  on public.answers
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- flashcards -----------------------------------------------------------------
alter table public.flashcards enable row level security;

create policy "flashcards_owner"
  on public.flashcards
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- flashcard_reviews ------------------------------------------------------
alter table public.flashcard_reviews enable row level security;

create policy "flashcard_reviews_owner"
  on public.flashcard_reviews
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
