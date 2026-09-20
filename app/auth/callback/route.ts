import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

// Endpoint de callback do fluxo PKCE do Supabase Auth. Usado tanto pela
// confirmação de cadastro quanto pela recuperação de senha: ambos os
// e-mails apontam para /auth/callback?code=...&next=..., trocamos o code
// por uma sessão (cookies) e redirecionamos para `next`.
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const next = searchParams.get('next') ?? '/dashboard'

  if (code) {
    const supabase = createClient()
    const { error } = await supabase.auth.exchangeCodeForSession(code)
    if (!error) {
      return NextResponse.redirect(`${origin}${next}`)
    }
  }

  return NextResponse.redirect(`${origin}/login?error=auth_callback_failed`)
}
