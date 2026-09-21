'use server'

import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL ?? 'http://localhost:3000'

/**
 * Autenticação via Supabase Auth (e-mail + senha).
 *
 * Convenção usada neste arquivo: como estas actions são chamadas
 * diretamente pelos componentes de formulário no cliente (não via
 * `<form action={...}>`), elas recebem objetos tipados em vez de FormData —
 * isso dá tipagem completa de ponta a ponta sem parsing manual.
 */

export async function signInAction(input: { email: string; password: string }): Promise<{ error?: string }> {
  const supabase = createClient()

  const { error } = await supabase.auth.signInWithPassword({
    email: input.email,
    password: input.password,
  })

  if (error) {
    return { error: traduzErro(error.message) }
  }

  redirect('/dashboard')
}

export async function signUpAction(input: {
  name: string
  email: string
  password: string
  devRequest?: boolean
}): Promise<{ error?: string; needsEmailConfirmation?: boolean }> {
  const supabase = createClient()

  const { data, error } = await supabase.auth.signUp({
    email: input.email,
    password: input.password,
    options: {
      data: { full_name: input.name, dev_request: input.devRequest ?? false },
      emailRedirectTo: `${siteUrl}/auth/callback?next=/dashboard`,
    },
  })

  if (error) {
    return { error: traduzErro(error.message) }
  }

  // Se a confirmação de e-mail estiver desligada no projeto Supabase, o
  // signUp já retorna uma sessão ativa e podemos ir direto pro dashboard.
  if (data.session) {
    redirect('/dashboard')
  }

  return { needsEmailConfirmation: true }
}

export async function forgotPasswordAction(input: { email: string }): Promise<{ success: true }> {
  const supabase = createClient()

  await supabase.auth.resetPasswordForEmail(input.email, {
    redirectTo: `${siteUrl}/auth/callback?next=/reset-password`,
  })

  // Sempre retorna sucesso, mesmo se o e-mail não existir, para não revelar
  // quais e-mails estão cadastrados.
  return { success: true }
}

export async function updatePasswordAction(input: { password: string }): Promise<{ error?: string }> {
  const supabase = createClient()

  const { error } = await supabase.auth.updateUser({ password: input.password })

  if (error) {
    return { error: traduzErro(error.message) }
  }

  await supabase.auth.signOut()
  redirect('/login?resetSuccess=1')
}

// Sem parâmetros: pode ser usada tanto via chamada direta quanto como
// `<form action={signOutAction}>` (Next ignora o FormData implícito).
export async function signOutAction() {
  const supabase = createClient()
  await supabase.auth.signOut()
  redirect('/login')
}

function traduzErro(message: string): string {
  const traducoes: Record<string, string> = {
    'Invalid login credentials': 'E-mail ou senha inválidos.',
    'User already registered': 'Já existe uma conta com este e-mail.',
    'Password should be at least 6 characters': 'A senha deve ter pelo menos 6 caracteres.',
    'Email not confirmed': 'Confirme seu e-mail antes de entrar.',
  }
  return traducoes[message] ?? message
}
