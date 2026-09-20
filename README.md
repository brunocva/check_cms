# Simulador de Provas

Simulador de provas pessoal: banco de questões com tags, simulados configuráveis,
dashboard de desempenho e flashcards com repetição espaçada.

**Stack:** Next.js 14 (App Router) + TypeScript, Tailwind CSS + componentes estilo shadcn/ui,
Recharts, Supabase (Auth + Postgres + RLS). Deploy em Vercel + Supabase (ambos com free tier).

## Estrutura do projeto

```
app/
  (auth)/          login, register, forgot-password, reset-password
  (dashboard)/     dashboard, simulado, progresso, questoes, flashcards
  auth/callback/   troca o "code" do link de e-mail por uma sessão (PKCE)
components/
  ui/              primitivos (button, input, card, badge, select...)
  auth/            formulários de autenticação
  simulado/        configuração, execução e resultado do simulado
  graficos/        gráficos Recharts do dashboard/progresso
  flashcards/      criação, listagem e modo de estudo (flip card)
  tags/            badge e CRUD de tags
  questoes/        CRUD de questões, filtros, matérias
  layout/          sidebar, topbar, tema
lib/
  supabase/        clients (browser/server) + tipos do banco
  sm2/             repetição espaçada simplificada
  actions/         Server Actions (auth, subjects, tags, questions, exam, flashcards)
  utils/           métricas do dashboard, formatação
supabase/
  migrations/      schema + triggers + RLS + índices (rodar em ordem)
  seed.sql         3 matérias, 5 tags, 15 questões de exemplo
```

## 1. Setup local

### Pré-requisitos

- Node.js 18.18+ (recomendado 20+)
- Uma conta [Supabase](https://supabase.com) (free tier é suficiente)

### Passo a passo

1. **Instale as dependências**

   ```bash
   cd simulador-provas
   npm install
   ```

2. **Crie um projeto no Supabase** em [supabase.com/dashboard](https://supabase.com/dashboard).

3. **Rode as migrations** — Supabase Studio → **SQL Editor** → cole e execute, **nesta ordem**,
   o conteúdo de cada arquivo em `supabase/migrations/`:

   1. `0001_init.sql` — tabelas
   2. `0002_functions_triggers.sql` — trigger que cria o `profile` no cadastro
   3. `0003_rls.sql` — Row Level Security (cada usuário só vê os próprios dados)
   4. `0004_indexes.sql` — índices

   (Se preferir, use a Supabase CLI: `supabase db push` apontando para os arquivos de migration.)

4. **Configure as variáveis de ambiente**

   ```bash
   cp .env.local.example .env.local
   ```

   Preencha com os valores de **Project Settings → API** no painel do Supabase:

   ```env
   NEXT_PUBLIC_SUPABASE_URL=https://SEU-PROJETO.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=sua-anon-key-publica
   NEXT_PUBLIC_SITE_URL=http://localhost:3000
   ```

5. **Configure os links de e-mail do Supabase Auth** (Authentication → URL Configuration):
   - **Site URL**: `http://localhost:3000` (troque pela URL da Vercel em produção)
   - **Redirect URLs**: adicione `http://localhost:3000/auth/callback` (e o equivalente em produção)

6. **Rode o app**

   ```bash
   npm run dev
   ```

   Acesse `http://localhost:3000`, clique em **Cadastre-se** e crie sua conta.

7. **(Opcional) Popule dados de exemplo** — depois de criar sua conta:
   - Abra `supabase/seed.sql`, troque `'seu-email@exemplo.com'` pelo e-mail que você cadastrou.
   - Cole o conteúdo no SQL Editor do Supabase e execute.
   - Isso cria 3 matérias, 5 tags (cálculo, interpretação, legislação, memorização,
     raciocínio lógico) e 15 questões já tageadas — dá pra simular na hora.

## 2. Como o app funciona (resumo técnico)

- **Auth**: Supabase Auth (e-mail/senha) com fluxo PKCE. `middleware.ts` renova a sessão a cada
  requisição e protege as rotas de `(dashboard)`; um trigger no banco (`handle_new_user`) cria a
  linha em `profiles` automaticamente no cadastro.
- **RLS**: toda tabela "dona" de dados tem uma policy `for all using/with check (auth.uid() = user_id)`.
  `question_tags` não tem `user_id` próprio — a posse é verificada via `EXISTS` na tabela `questions`.
- **Server Actions**: ações chamadas diretamente do client (ex.: criar questão) recebem objetos
  TypeScript tipados; ações usadas como `<form action={...}>` dentro de Server Components (ex.:
  excluir, criar flashcard de uma questão) recebem `FormData`. Ambas convenções estão comentadas
  nos arquivos de `lib/actions/`.
- **SM-2 simplificado** (`lib/sm2/index.ts`): em vez do "ease factor" contínuo do SM-2 original,
  usa intervalos fixos por autoavaliação — Errei = hoje, Difícil = 1 dia, Bom = 3 dias, Fácil = 7
  dias — e promove o cartão a "dominado" após algumas repetições boas seguidas.
- **Métricas do dashboard** (`lib/utils/metrics.ts`): buscamos as tabelas separadamente (poucas
  linhas, uso pessoal) e agregamos em memória — mais simples de ler/testar do que PostgREST com
  embeds aninhados em várias tabelas.

## 3. Deploy (Vercel + Supabase)

1. Suba o repositório para o GitHub (se ainda não estiver lá).
2. No [Vercel](https://vercel.com), **New Project** → importe o repositório → aponte o
   **Root Directory** para `simulador-provas` (caso o repo tenha outras pastas na raiz).
3. Em **Environment Variables**, adicione as mesmas três variáveis do `.env.local`, trocando
   `NEXT_PUBLIC_SITE_URL` pela URL final do deploy (ex.: `https://seu-app.vercel.app`).
4. Deploy.
5. No Supabase, atualize **Authentication → URL Configuration**:
   - **Site URL**: `https://seu-app.vercel.app`
   - **Redirect URLs**: adicione `https://seu-app.vercel.app/auth/callback`
6. Rode as migrations (passo 3 da seção acima) no projeto Supabase de produção, caso ainda não
   tenha rodado.

Pronto — cadastro, simulados, dashboard e flashcards funcionando em produção, tudo no free tier.

## Scripts

```bash
npm run dev        # ambiente de desenvolvimento
npm run build      # build de produção
npm run start      # roda o build de produção localmente
npm run lint       # eslint
npm run typecheck  # tsc --noEmit
```

## Aviso

Este é um projeto pessoal de estudo. As perguntas de exemplo no `seed.sql` são apoio de
memorização e **não substituem o material oficial** de qualquer curso ou certificação.
