-- =============================================================================
-- 0004_indexes.sql
-- Índices para as consultas mais comuns (filtros por usuário/matéria/tag e
-- os joins usados no dashboard e no simulador).
-- =============================================================================

create index if not exists idx_subjects_user on public.subjects (user_id);
create index if not exists idx_tags_user on public.tags (user_id);

create index if not exists idx_questions_user on public.questions (user_id);
create index if not exists idx_questions_subject on public.questions (subject_id);

create index if not exists idx_question_tags_tag on public.question_tags (tag_id);
create index if not exists idx_question_tags_question on public.question_tags (question_id);

create index if not exists idx_exam_sessions_user on public.exam_sessions (user_id, finished_at);

create index if not exists idx_answers_session on public.answers (session_id);
create index if not exists idx_answers_user on public.answers (user_id);
create index if not exists idx_answers_question on public.answers (question_id);

create index if not exists idx_flashcards_user on public.flashcards (user_id);
create index if not exists idx_flashcards_next_review on public.flashcards (user_id, next_review_date);
create index if not exists idx_flashcards_question on public.flashcards (question_id);

create index if not exists idx_flashcard_reviews_flashcard on public.flashcard_reviews (flashcard_id);
