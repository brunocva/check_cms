'use server'

import { redirect } from 'next/navigation'
import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import type { Difficulty, ExamMode } from '@/lib/types'

type SupabaseServerClient = ReturnType<typeof createClient>

interface QuestionFilters {
  subjectId?: string | null
  tagId?: string | null
  difficulty?: Difficulty | null
}

/**
 * Resolve os ids de questões elegíveis para os filtros do modo escolhido.
 * O filtro por tag passa primeiro por question_tags (N:N) e depois é
 * interseccionado com os demais filtros feitos direto em `questions`.
 */
async function getEligibleQuestionIds(supabase: SupabaseServerClient, filters: QuestionFilters): Promise<string[]> {
  let query = supabase.from('questions').select('id')

  if (filters.subjectId) query = query.eq('subject_id', filters.subjectId)
  if (filters.difficulty) query = query.eq('difficulty', filters.difficulty)

  if (filters.tagId) {
    const { data: tagRows } = await supabase.from('question_tags').select('question_id').eq('tag_id', filters.tagId)
    const idsWithTag = (tagRows ?? []).map((r) => r.question_id)
    if (idsWithTag.length === 0) return []
    query = query.in('id', idsWithTag)
  }

  const { data, error } = await query
  if (error || !data) return []
  return data.map((q) => q.id)
}

function shuffle<T>(items: T[]): T[] {
  const copy = [...items]
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[copy[i], copy[j]] = [copy[j], copy[i]]
  }
  return copy
}

// Chamada diretamente do ConfigForm (client component).
export async function createExamSession(input: {
  mode: ExamMode
  subjectId?: string | null
  tagId?: string | null
  amount: number
  difficulty?: Difficulty | null
}): Promise<{ error?: string }> {
  const supabase = createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { error: 'Não autenticado.' }

  // Cada modo só respeita os filtros que fazem sentido para ele: "materia"
  // ignora tag/dificuldade, "tag" ignora matéria/dificuldade, e apenas
  // "personalizada" combina os três.
  const filters: QuestionFilters = {
    subjectId: input.mode === 'materia' || input.mode === 'personalizada' ? input.subjectId ?? null : null,
    tagId: input.mode === 'tag' || input.mode === 'personalizada' ? input.tagId ?? null : null,
    difficulty: input.mode === 'personalizada' ? input.difficulty ?? null : null,
  }

  const eligibleIds = await getEligibleQuestionIds(supabase, filters)
  if (eligibleIds.length === 0) {
    return { error: 'Nenhuma questão encontrada com esses filtros. Cadastre questões antes de simular.' }
  }

  const selected = shuffle(eligibleIds).slice(0, input.amount)

  const { data: session, error } = await supabase
    .from('exam_sessions')
    .insert({
      user_id: user.id,
      mode: input.mode,
      subject_id: filters.subjectId,
      tag_id: filters.tagId,
      question_ids: selected,
      total_questions: selected.length,
    })
    .select('id')
    .single()

  if (error || !session) return { error: error?.message ?? 'Erro ao criar o simulado.' }

  redirect(`/simulado/${session.id}`)
}

// Chamada diretamente do ExamRunner (client component) ao finalizar a prova.
export async function finishExamSession(input: {
  sessionId: string
  answers: { questionId: string; selectedOption: string }[]
}): Promise<{ error?: string }> {
  const supabase = createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { error: 'Não autenticado.' }

  const { data: session } = await supabase
    .from('exam_sessions')
    .select('id, finished_at, question_ids')
    .eq('id', input.sessionId)
    .single()

  if (!session) return { error: 'Simulado não encontrado.' }

  // Idempotência: se já foi finalizado (ex.: duplo clique), só redireciona.
  if (session.finished_at) {
    redirect(`/simulado/${input.sessionId}/resultado`)
  }

  const { data: questions } = await supabase
    .from('questions')
    .select('id, correct_option')
    .in('id', session.question_ids)

  const correctByQuestion = new Map((questions ?? []).map((q) => [q.id, q.correct_option]))

  const rows = input.answers.map((a) => ({
    session_id: input.sessionId,
    user_id: user.id,
    question_id: a.questionId,
    selected_option: a.selectedOption,
    is_correct: correctByQuestion.get(a.questionId) === a.selectedOption,
  }))

  if (rows.length > 0) {
    const { error: answersError } = await supabase.from('answers').insert(rows)
    if (answersError) return { error: answersError.message }
  }

  const correctCount = rows.filter((r) => r.is_correct).length
  const total = session.question_ids.length
  const score = total > 0 ? Math.round((correctCount / total) * 1000) / 10 : 0

  await supabase
    .from('exam_sessions')
    .update({ correct_count: correctCount, score, finished_at: new Date().toISOString() })
    .eq('id', input.sessionId)

  revalidatePath('/dashboard')
  revalidatePath('/progresso')
  redirect(`/simulado/${input.sessionId}/resultado`)
}
