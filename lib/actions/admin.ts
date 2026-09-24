'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { assertIsAdmin } from '@/lib/supabase/require-admin'

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
