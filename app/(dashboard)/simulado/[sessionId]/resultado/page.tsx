import Link from 'next/link'
import { notFound, redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { ResultSummary } from '@/components/simulado/result-summary'
import { GabaritoList, type GabaritoItem } from '@/components/simulado/gabarito-list'
import { SubmitButton } from '@/components/shared/submit-button'
import { Button } from '@/components/ui/button'
import { generateFlashcardsFromWrongAnswers } from '@/lib/actions/flashcards'

export default async function ResultadoPage({
  params,
  searchParams,
}: {
  params: { sessionId: string }
  searchParams: { flashcards?: string }
}) {
  const supabase = createClient()

  const { data: session } = await supabase
    .from('exam_sessions')
    .select('id, question_ids, finished_at, correct_count, total_questions, score')
    .eq('id', params.sessionId)
    .maybeSingle()

  if (!session) notFound()
  if (!session.finished_at) redirect(`/simulado/${session.id}`)

  const [{ data: answers }, { data: questions }] = await Promise.all([
    supabase.from('answers').select('question_id, selected_option, is_correct').eq('session_id', session.id),
    supabase.from('questions').select('id, statement, options, correct_option, explanation').in('id', session.question_ids),
  ])

  const questionById = new Map((questions ?? []).map((q) => [q.id, q]))
  const answerByQuestion = new Map((answers ?? []).map((a) => [a.question_id, a]))

  const items: GabaritoItem[] = session.question_ids
    .map((questionId) => {
      const question = questionById.get(questionId)
      const answer = answerByQuestion.get(questionId)
      if (!question || !answer) return null
      return {
        questionId,
        statement: question.statement,
        options: question.options,
        correctOption: question.correct_option,
        explanation: question.explanation,
        selectedOption: answer.selected_option,
        isCorrect: answer.is_correct,
      }
    })
    .filter((item): item is GabaritoItem => Boolean(item))

  const hasWrongAnswers = items.some((item) => !item.isCorrect)

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      {searchParams.flashcards === 'none' && (
        <p className="rounded-md bg-muted p-3 text-sm">Você não errou nenhuma questão — nada para gerar. 🎉</p>
      )}
      {searchParams.flashcards && searchParams.flashcards !== 'none' && (
        <p className="rounded-md bg-success/10 p-3 text-sm text-success">
          {searchParams.flashcards} flashcard(s) criado(s) a partir das questões erradas.
        </p>
      )}

      <ResultSummary correct={session.correct_count} total={session.total_questions} score={session.score} />

      <div className="flex flex-wrap gap-2">
        {hasWrongAnswers && (
          <form action={generateFlashcardsFromWrongAnswers}>
            <input type="hidden" name="sessionId" value={session.id} />
            <SubmitButton pendingText="Gerando...">Gerar flashcards das questões erradas</SubmitButton>
          </form>
        )}
        <Button asChild variant="outline">
          <Link href="/simulado">Novo simulado</Link>
        </Button>
      </div>

      <div>
        <h2 className="mb-3 text-lg font-semibold">Gabarito comentado</h2>
        <GabaritoList items={items} />
      </div>
    </div>
  )
}
