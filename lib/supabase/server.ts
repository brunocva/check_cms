import { cookies } from 'next/headers'
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import type { Database } from './types'

// Client Supabase para uso em Server Components, Server Actions e Route
// Handlers. Lê/escreve os cookies de sessão via a API cookies() do Next, o
// que mantém o usuário autenticado entre requisições (RLS usa auth.uid()
// extraído desse cookie/JWT).
export function createClient() {
  const cookieStore = cookies()

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet: { name: string; value: string; options: CookieOptions }[]) {
          try {
            cookiesToSet.forEach(({ name, value, options }) => cookieStore.set(name, value, options))
          } catch {
            // set() chamado a partir de um Server Component durante a
            // renderização (sem Response mutável). Pode ser ignorado com
            // segurança: o middleware já atualiza o cookie de sessão em
            // toda requisição.
          }
        },
      },
    }
  )
}
