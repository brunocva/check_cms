'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { computeNextReview } from '@/lib/sm2'
import type { FlashcardRating, QuestionOption } from '@/lib/types'

function buildBack(question: { options: QuestionOption[]; correct_option: string; explanation: string | null }) {
  const correct = question.options.find((o) => o.key === question.correct_option)
  const answerText = correct ? `${correct.key}) ${correct.text}` : question.correct_option
  return question.explanation ? `${answerText}\n\n${question.explanation}` : answerText
}

// Usada como `<form action={createFlashcardFromQuestion}>` na listagem de questões.
export async function createFlashcardFromQuestion(formData: FormData) {
  const questionId = String(formData.get('questionId') ?? '')
  if (!questionId) return

  const supabase = createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return

  // Evita duplicar flashcard se o usuário clicar mais de uma vez.
  const { data: existing } = await supabase.from('flashcards').select('id').eq('question_id', questionId).maybeSingle()
  if (existing) {
    revalidatePath('/questoes')
    return
  }

  const { data: question } = await supabase
    .from('questions')
    .select('statement, options, correct_option, explanation, subject_id')
    .eq('id', questionId)
    .single()
  if (!question) return

  await supabase.from('flashcards').insert({
    user_id: user.id,
    question_id: questionId,
    subject_id: question.subject_id,
    front: question.statement,
    back: buildBack(question),
  })

  revalidatePath('/questoes')
  revalidatePath('/flashcards')
}

// Usada como `<form action={generateFlashcardsFromWrongAnswers}>` na página de resultado do simulado.
export async function generateFlashcardsFromWrongAnswers(formData: FormData) {
  const sessionId = String(formData.get('sessionId') ?? '')
  if (!sessionId) return

  const supabase = createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return

  const { data: wrongAnswers } = await supabase
    .from('answers')
    .select('question_id')
    .eq('session_id', sessionId)
    .eq('is_correct', false)

  const questionIds = Array.from(new Set((wrongAnswers ?? []).map((a) => a.question_id)))

  if (questionIds.length === 0) {
    redirect(`/simulado/${sessionId}/resultado?flashcards=none`)
  }

  const { data: existingCards } = await supabase.from('flashcards').select('question_id').in('question_id', questionIds)
  const alreadyHasCard = new Set((existingCards ?? []).map((c) => c.question_id))
  const toCreate = questionIds.filter((id) => !alreadyHasCard.has(id))

  if (toCreate.length > 0) {
    const { data: questions } = await supabase
      .from('questions')
      .select('id, statement, options, correct_option, explanation, subject_id')
      .in('id', toCreate)

    const rows = (questions ?? []).map((q) => ({
      user_id: user.id,
      question_id: q.id,
      subject_id: q.subject_id,
      front: q.statement,
      back: buildBack(q),
    }))

    if (rows.length > 0) await supabase.from('flashcards').insert(rows)
  }

  revalidatePath('/flashcards')
  redirect(`/simulado/${sessionId}/resultado?flashcards=${toCreate.length}`)
}

// Chamada diretamente do FlashcardForm (client component) para criação manual.
export async function createFlashcard(input: {
  front: string
  back: string
  subjectId: string | null
}): Promise<{ error?: string }> {
  const supabase = createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { error: 'Não autenticado.' }

  if (!input.front.trim() || !input.back.trim()) {
    return { error: 'Preencha a frente e o verso do cartão.' }
  }

  const { error } = await supabase.from('flashcards').insert({
    user_id: user.id,
    subject_id: input.subjectId,
    front: input.front.trim(),
    back: input.back.trim(),
  })

  if (error) return { error: error.message }

  revalidatePath('/flashcards')
  return {}
}

// Usada como `<form action={deleteFlashcard}>`.
export async function deleteFlashcard(formData: FormData) {
  const id = String(formData.get('id') ?? '')
  if (!id) return

  const supabase = createClient()
  await supabase.from('flashcards').delete().eq('id', id)

  revalidatePath('/flashcards')
}

// Chamada diretamente do StudySession (client component) a cada autoavaliação.
// Aplica a repetição espaçada simplificada (lib/sm2) e registra o histórico.
export async function reviewFlashcard(input: {
  flashcardId: string
  rating: FlashcardRating
}): Promise<{ error?: string }> {
  const supabase = createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { error: 'Não autenticado.' }

  const { data: card } = await supabase
    .from('flashcards')
    .select('status, repetitions, interval_days')
    .eq('id', input.flashcardId)
    .single()
  if (!card) return { error: 'Cartão não encontrado.' }

  const next = computeNextReview(card, input.rating)

  const { error: updateError } = await supabase
    .from('flashcards')
    .update({
      status: next.status,
      repetitions: next.repetitions,
      interval_days: next.interval_days,
      next_review_date: next.next_review_date,
    })
    .eq('id', input.flashcardId)
  if (updateError) return { error: updateError.message }

  await supabase.from('flashcard_reviews').insert({
    flashcard_id: input.flashcardId,
    user_id: user.id,
    rating: input.rating,
  })

  revalidatePath('/flashcards')
  return {}
}
