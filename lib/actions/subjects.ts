'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { assertIsAdmin } from '@/lib/supabase/require-admin'

// createSubject é chamada diretamente do client (SubjectManager) -> objeto tipado.
// Matérias são compartilhadas com todos os usuários (RLS: leitura livre, escrita
// só admin) — a checagem abaixo é só para dar um erro mais claro; o banco já bloqueia.
export async function createSubject(input: { name: string }): Promise<{ error?: string }> {
  const supabase = createClient()

  const authError = await assertIsAdmin(supabase)
  if (authError) return { error: authError }

  const {
    data: { user },
  } = await supabase.auth.getUser()

  const name = input.name.trim()
  if (!name) return { error: 'Informe um nome para a matéria.' }

  const { error } = await supabase.from('subjects').insert({ user_id: user!.id, name })

  if (error) {
    if (error.code === '23505') return { error: 'Já existe uma matéria com esse nome.' }
    return { error: error.message }
  }

  revalidatePath('/questoes')
  revalidatePath('/simulado')
  return {}
}

// deleteSubject é usada como `<form action={deleteSubject}>` num Server
// Component, por isso recebe FormData.
export async function deleteSubject(formData: FormData) {
  const id = String(formData.get('id') ?? '')
  if (!id) return

  const supabase = createClient()

  const authError = await assertIsAdmin(supabase)
  if (authError) return

  await supabase.from('subjects').delete().eq('id', id)

  revalidatePath('/questoes')
  revalidatePath('/simulado')
}
