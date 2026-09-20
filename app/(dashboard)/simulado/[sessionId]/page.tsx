import { notFound, redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { ExamRunner } from '@/components/simulado/exam-runner'

export default async function SimuladoRunnerPage({ params }: { params: { sessionId: string } }) {
  const supabase = createClient()

  const { data: session } = await supabase
    .from('exam_sessions')
    .select('id, question_ids, finished_at')
    .eq('id', params.sessionId)
    .maybeSingle()

  if (!session) notFound()
  if (session.finished_at) redirect(`/simulado/${session.id}/resultado`)

  // Nunca selecionamos correct_option/explanation aqui: enquanto a prova
  // está em andamento, o cliente não deve ter acesso ao gabarito.
  const { data: questions } = await supabase.from('questions').select('id, statement, options').in('id', session.question_ids)

  const byId = new Map((questions ?? []).map((q) => [q.id, q]))
  const orderedQuestions = session.question_ids
    .map((id) => byId.get(id))
    .filter((q): q is NonNullable<typeof q> => Boolean(q))

  return (
    <div className="mx-auto max-w-2xl">
      <ExamRunner sessionId={session.id} questions={orderedQuestions} />
    </div>
  )
}
