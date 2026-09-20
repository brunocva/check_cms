'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'

export async function createTag(input: { name: string; color: string }): Promise<{ error?: string }> {
  const supabase = createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { error: 'Não autenticado.' }

  const name = input.name.trim()
  if (!name) return { error: 'Informe um nome para a tag.' }

  const { error } = await supabase.from('tags').insert({ user_id: user.id, name, color: input.color })

  if (error) {
    if (error.code === '23505') return { error: 'Você já tem uma tag com esse nome.' }
    return { error: error.message }
  }

  revalidatePath('/questoes')
  revalidatePath('/simulado')
  revalidatePath('/flashcards')
  return {}
}

export async function updateTag(input: { id: string; name: string; color: string }): Promise<{ error?: string }> {
  const supabase = createClient()

  const { error } = await supabase
    .from('tags')
    .update({ name: input.name.trim(), color: input.color })
    .eq('id', input.id)

  if (error) return { error: error.message }

  revalidatePath('/questoes')
  revalidatePath('/simulado')
  revalidatePath('/flashcards')
  return {}
}

// Usada como `<form action={deleteTag}>`.
export async function deleteTag(formData: FormData) {
  const id = String(formData.get('id') ?? '')
  if (!id) return

  const supabase = createClient()
  await supabase.from('tags').delete().eq('id', id)

  revalidatePath('/questoes')
  revalidatePath('/simulado')
  revalidatePath('/flashcards')
}
