'use server'

import { redirect } from 'next/navigation'
import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { assertIsAdmin } from '@/lib/supabase/require-admin'
import type { Difficulty, QuestionOption } from '@/lib/types'

export interface QuestionInput {
  statement: string
  subjectId: string | null
  difficulty: Difficulty
  options: QuestionOption[]
  correctOption: string
  explanation: string
  tagIds: string[]
}

function validate(input: QuestionInput): string | null {
  if (!input.statement.trim()) return 'Escreva o enunciado da questão.'
  const validOptions = input.options.filter((o) => o.text.trim())
  if (validOptions.length < 2) return 'Informe pelo menos 2 alternativas.'
  if (!input.correctOption || !validOptions.some((o) => o.key === input.correctOption)) {
    return 'Selecione qual alternativa é a correta.'
  }
  return null
}

// Chamada diretamente do QuestionForm (client component) -> objeto tipado.
export async function createQuestion(input: QuestionInput): Promise<{ error?: string; id?: string }> {
  const supabase = createClient()

  const authError = await assertIsAdmin(supabase)
  if (authError) return { error: authError }

  const {
    data: { user },
  } = await supabase.auth.getUser()

  const validationError = validate(input)
  if (validationError) return { error: validationError }

  const options = input.options.filter((o) => o.text.trim())

  const { data, error } = await supabase
    .from('questions')
    .insert({
      user_id: user!.id,
      subject_id: input.subjectId,
      statement: input.statement.trim(),
      options,
      correct_option: input.correctOption,
      explanation: input.explanation.trim() || null,
      difficulty: input.difficulty,
    })
    .select('id')
    .single()

  if (error || !data) return { error: error?.message ?? 'Erro ao criar questão.' }

  if (input.tagIds.length > 0) {
    await supabase.from('question_tags').insert(input.tagIds.map((tagId) => ({ question_id: data.id, tag_id: tagId })))
  }

  revalidatePath('/questoes')
  redirect('/questoes')
}

export async function updateQuestion(
  input: QuestionInput & { id: string }
): Promise<{ error?: string }> {
  const supabase = createClient()

  const authError = await assertIsAdmin(supabase)
  if (authError) return { error: authError }

  const validationError = validate(input)
  if (validationError) return { error: validationError }

  const options = input.options.filter((o) => o.text.trim())

  const { error } = await supabase
    .from('questions')
    .update({
      subject_id: input.subjectId,
      statement: input.statement.trim(),
      options,
      correct_option: input.correctOption,
      explanation: input.explanation.trim() || null,
      difficulty: input.difficulty,
    })
    .eq('id', input.id)

  if (error) return { error: error.message }

  // Substitui as associações de tags (delete-then-insert; simples e
  // suficiente para o volume de dados de um projeto pessoal).
  await supabase.from('question_tags').delete().eq('question_id', input.id)
  if (input.tagIds.length > 0) {
    await supabase.from('question_tags').insert(input.tagIds.map((tagId) => ({ question_id: input.id, tag_id: tagId })))
  }

  revalidatePath('/questoes')
  redirect('/questoes')
}

// Usada como `<form action={deleteQuestion}>` num Server Component.
export async function deleteQuestion(formData: FormData) {
  const id = String(formData.get('id') ?? '')
  if (!id) return

  const supabase = createClient()

  const authError = await assertIsAdmin(supabase)
  if (authError) return

  await supabase.from('questions').delete().eq('id', id)

  revalidatePath('/questoes')
}
