-- =============================================================================
-- 0006_shared_content.sql
-- Modelo compartilhado para o banco de questões: subjects, tags, questions e
-- question_tags deixam de ser privados por usuário e passam a ser "todo
-- mundo autenticado lê, só admin escreve". Isso substitui o processo manual
-- de rodar o seed.sql para cada usuário novo — a partir de agora, qualquer
-- pessoa que se cadastrar já enxerga o mesmo banco de questões.
--
-- NÃO muda: exam_sessions, answers, flashcards, flashcard_reviews e profiles
-- continuam privados por usuário (auth.uid() = user_id) — o histórico e o
-- progresso de cada pessoa continuam isolados.
--
-- `user_id` nessas quatro tabelas passa a ser só metadado de "quem criou"
-- (útil para auditoria futura), não é mais usado para controle de acesso.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Unicidade de nome deixa de ser por usuário (não faz mais sentido duas
-- matérias/tags com o mesmo nome existirem "para usuários diferentes" quando
-- todo mundo enxerga a mesma lista).
-- -----------------------------------------------------------------------------
alter table public.subjects drop constraint if exists subjects_user_id_name_key;
alter table public.subjects add constraint subjects_name_key unique (name);

alter table public.tags drop constraint if exists tags_user_id_name_key;
alter table public.tags add constraint tags_name_key unique (name);

-- -----------------------------------------------------------------------------
-- Novas policies: leitura liberada para qualquer usuário autenticado,
-- escrita (insert/update/delete) restrita a admins.
-- -----------------------------------------------------------------------------

-- subjects -------------------------------------------------------------------
drop policy if exists "subjects_owner" on public.subjects;

drop policy if exists "subjects_read_all" on public.subjects;
create policy "subjects_read_all"
  on public.subjects
  for select
  using (auth.role() = 'authenticated');

drop policy if exists "subjects_admin_write" on public.subjects;
create policy "subjects_admin_write"
  on public.subjects
  for all
  using (public.is_admin())
  with check (public.is_admin());

-- tags -------------------------------------------------------------------------
drop policy if exists "tags_owner" on public.tags;

drop policy if exists "tags_read_all" on public.tags;
create policy "tags_read_all"
  on public.tags
  for select
  using (auth.role() = 'authenticated');

drop policy if exists "tags_admin_write" on public.tags;
create policy "tags_admin_write"
  on public.tags
  for all
  using (public.is_admin())
  with check (public.is_admin());

-- questions --------------------------------------------------------------------
drop policy if exists "questions_owner" on public.questions;

drop policy if exists "questions_read_all" on public.questions;
create policy "questions_read_all"
  on public.questions
  for select
  using (auth.role() = 'authenticated');

drop policy if exists "questions_admin_write" on public.questions;
create policy "questions_admin_write"
  on public.questions
  for all
  using (public.is_admin())
  with check (public.is_admin());

-- question_tags ------------------------------------------------------------------
drop policy if exists "question_tags_owner" on public.question_tags;

drop policy if exists "question_tags_read_all" on public.question_tags;
create policy "question_tags_read_all"
  on public.question_tags
  for select
  using (auth.role() = 'authenticated');

drop policy if exists "question_tags_admin_write" on public.question_tags;
create policy "question_tags_admin_write"
  on public.question_tags
  for all
  using (public.is_admin())
  with check (public.is_admin());
