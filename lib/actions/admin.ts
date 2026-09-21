'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'

// Verificação defensiva extra além do RLS: o próprio banco já bloqueia (via
// policy + trigger) qualquer tentativa de um não-admin alterar is_admin, mas
// checar aqui evita uma chamada desnecessária ao banco e dá um erro mais claro.
async function assertIsAdmin(supabase: ReturnType<typeof createClient>): Promise<string | null> {
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return 'Você precisa estar autenticado.'

  const { data: profile } = await supabase.from('profiles').select('is_admin').eq('id', user.id).single()
  if (!profile?.is_admin) return 'Apenas administradores podem fazer isso.'

  return null
}

// Aprova uma solicitação de acesso de desenvolvedor: marca is_admin = true.
// A trigger prevent_is_admin_escalation() só permite essa troca porque quem
// está autenticado nesta chamada já é admin (verificado pela RLS).
export async function approveDeveloperRequest(userId: string): Promise<{ error?: string }> {
  const supabase = createClient()

  const authError = await assertIsAdmin(supabase)
  if (authError) return { error: authError }

  const { error } = await supabase.from('profiles').update({ is_admin: true }).eq('id', userId)
  if (error) return { error: 'Não foi possível aprovar a solicitação.' }

  revalidatePath('/admin/solicitacoes')
  return {}
}

// Rejeita a solicitação sem promover a conta: a pessoa continua com uma
// conta comum, só deixa de aparecer como "pendente".
export async function rejectDeveloperRequest(userId: string): Promise<{ error?: string }> {
  const supabase = createClient()

  const authError = await assertIsAdmin(supabase)
  if (authError) return { error: authError }

  const { error } = await supabase.from('profiles').update({ admin_requested_at: null }).eq('id', userId)
  if (error) return { error: 'Não foi possível rejeitar a solicitação.' }

  revalidatePath('/admin/solicitacoes')
  return {}
}
