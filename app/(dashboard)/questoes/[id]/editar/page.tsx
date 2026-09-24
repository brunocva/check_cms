import { notFound, redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { QuestionForm } from '@/components/questoes/question-form'

export default async function EditarQuestaoPage({ params }: { params: { id: string } }) {
  const supabase = createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: profile } = await supabase.from('profiles').select('is_admin').eq('id', user.id).single()
  if (!profile?.is_admin) redirect('/questoes')

  const [{ data: subjects }, { data: tags }, { data: question }, { data: questionTags }] = await Promise.all([
    supabase.from('subjects').select('*').order('name'),
    supabase.from('tags').select('*').order('name'),
    supabase.from('questions').select('*').eq('id', params.id).maybeSingle(),
    supabase.from('question_tags').select('tag_id').eq('question_id', params.id),
  ])

  if (!question) notFound()

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">Editar questão</h1>
        <p className="text-sm text-muted-foreground">Atualize o enunciado, alternativas ou tags.</p>
      </div>
      <QuestionForm
        subjects={subjects ?? []}
        tags={tags ?? []}
        initialQuestion={{ ...question, tagIds: (questionTags ?? []).map((qt) => qt.tag_id) }}
      />
    </div>
  )
}
