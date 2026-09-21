-- =============================================================================
-- 0005_admin.sql
-- Papel de administrador (desenvolvedor) sobre public.profiles:
--   - Cadastro normal: usuário comum, dados privados (respostas, sessões,
--     flashcards continuam isolados por auth.uid() = user_id, sem mudança).
--   - Cadastro como desenvolvedor: cria a conta normalmente, mas fica em
--     estado "pendente" (admin_requested_at preenchido, is_admin = false)
--     até que um admin já existente aprove pelo painel /admin/solicitacoes.
--
-- A coluna `email` é uma cópia de auth.users.email dentro de profiles: como
-- o schema `auth` não é exposto pela API do Supabase, sem essa cópia o
-- painel de administração não teria como mostrar o e-mail de quem pediu
-- acesso.
-- =============================================================================

alter table public.profiles
  add column if not exists email text,
  add column if not exists is_admin boolean not null default false,
  add column if not exists admin_requested_at timestamptz;

-- Backfill do e-mail para contas já existentes.
update public.profiles p
set email = u.email
from auth.users u
where u.id = p.id and p.email is null;

-- -----------------------------------------------------------------------------
-- handle_new_user: agora também copia o e-mail e, se o cadastro foi feito
-- pela tela "Cadastrar desenvolvedor" (metadata dev_request = true), marca
-- o pedido como pendente de aprovação.
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, admin_requested_at)
  values (
    new.id,
    new.raw_user_meta_data ->> 'full_name',
    new.email,
    case when (new.raw_user_meta_data ->> 'dev_request')::boolean is true then now() else null end
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- is_admin(): true se o usuário autenticado atual é administrador. Usada nas
-- políticas de RLS que dão acesso ampliado a admins (ver abaixo) e no
-- front-end/back-end para decidir o que mostrar/permitir.
-- `security definer` evita depender da própria RLS de profiles para se ler.
-- -----------------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select coalesce((select is_admin from public.profiles where id = auth.uid()), false);
$$;

-- -----------------------------------------------------------------------------
-- Trava contra auto-promoção: um usuário comum não pode simplesmente dar
-- UPDATE profiles SET is_admin = true no próprio registro. A troca de
-- is_admin só é aceita quando:
--   - não há contexto de usuário autenticado (auth.uid() é null), ou seja,
--     é uma alteração manual feita direto no SQL Editor pelo dono do
--     projeto (bootstrap do primeiro admin); ou
--   - quem está fazendo a alteração já é admin (aprovação de um novo
--     desenvolvedor pelo painel).
-- -----------------------------------------------------------------------------
create or replace function public.prevent_is_admin_escalation()
returns trigger
language plpgsql
as $$
begin
  if new.is_admin is distinct from old.is_admin then
    if auth.uid() is not null and not public.is_admin() then
      new.is_admin := old.is_admin;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_protect_is_admin on public.profiles;
create trigger trg_protect_is_admin
  before update on public.profiles
  for each row execute function public.prevent_is_admin_escalation();

-- -----------------------------------------------------------------------------
-- RLS: admins passam a enxergar e atualizar qualquer perfil (necessário para
-- listar e aprovar solicitações de desenvolvedor). A policy "profiles_owner"
-- original continua valendo para o caso comum (cada um vê o próprio perfil).
-- -----------------------------------------------------------------------------
drop policy if exists "profiles_admin_select" on public.profiles;
create policy "profiles_admin_select"
  on public.profiles
  for select
  using (public.is_admin());

drop policy if exists "profiles_admin_update" on public.profiles;
create policy "profiles_admin_update"
  on public.profiles
  for update
  using (public.is_admin())
  with check (public.is_admin());
