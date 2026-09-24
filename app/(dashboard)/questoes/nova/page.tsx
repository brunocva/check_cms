import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { QuestionForm } from '@/components/questoes/question-form'

export default async function NovaQuestaoPage() {
  const supabase = createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: profile } = await supabase.from('profiles').select('is_admin').eq('id', user.id).single()
  if (!profile?.is_admin) redirect('/questoes')

  const [{ data: subjects }, { data: tags }] = await Promise.all([
    supabase.from('subjects').select('*').order('name'),
    supabase.from('tags').select('*').order('name'),
  ])

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">Nova questão</h1>
        <p className="text-sm text-muted-foreground">Cadastre uma questão de múltipla escolha.</p>
      </div>
      <QuestionForm subjects={subjects ?? []} tags={tags ?? []} />
    </div>
  )
}
