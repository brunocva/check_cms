import type { createClient } from '@/lib/supabase/server'

// Verificação defensiva além do RLS: as policies do banco já bloqueiam
// escrita de não-admins em subjects/tags/questions/question_tags e em
// profiles.is_admin, mas checar aqui evita uma chamada desnecessária ao
// banco e devolve uma mensagem de erro mais clara para a UI.
export async function assertIsAdmin(supabase: ReturnType<typeof createClient>): Promise<string | null> {
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return 'Você precisa estar autenticado.'

  const { data: profile } = await supabase.from('profiles').select('is_admin').eq('id', user.id).single()
  if (!profile?.is_admin) return 'Apenas administradores podem editar o banco de questões.'

  return null
}
