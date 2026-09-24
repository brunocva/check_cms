import { createClient as createSupabaseClient } from '@supabase/supabase-js'
import type { Database } from './types'

// Client com a service_role key: ignora RLS por completo e tem permissão de
// admin sobre o projeto inteiro (ex: confirmar e-mail de qualquer usuário).
//
// USO RESTRITO: só pode ser chamado em código de servidor (Server Actions,
// Route Handlers) — NUNCA em um arquivo 'use client', nem exposto via props
// para o navegador. A env var não tem prefixo NEXT_PUBLIC_ justamente para
// nunca ser incluída no bundle enviado ao cliente.
export function createAdminClient() {
  return createSupabaseClient<Database>(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!, {
    auth: { autoRefreshToken: false, persistSession: false },
  })
}
