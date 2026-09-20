-- =============================================================================
-- 0002_functions_triggers.sql
-- Funções auxiliares e triggers.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- handle_new_user: copia todo novo usuário de auth.users para public.profiles.
-- `security definer` é necessário porque esta função roda no contexto do
-- trigger (não do usuário autenticado) e precisa inserir em profiles antes de
-- qualquer política de RLS "auth.uid() = id" poder ser satisfeita normalmente.
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- -----------------------------------------------------------------------------
-- set_updated_at: mantém flashcards.updated_at em dia a cada UPDATE.
-- -----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists flashcards_set_updated_at on public.flashcards;
create trigger flashcards_set_updated_at
  before update on public.flashcards
  for each row execute procedure public.set_updated_at();
