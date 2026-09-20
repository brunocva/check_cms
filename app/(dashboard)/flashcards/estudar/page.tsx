import { createClient } from '@/lib/supabase/server'
import { StudySession } from '@/components/flashcards/study-session'

export default async function EstudarPage() {
  const supabase = createClient()
  const today = new Date().toISOString().slice(0, 10)

  const { data: flashcards } = await supabase
    .from('flashcards')
    .select('id, front, back')
    .lte('next_review_date', today)
    .order('next_review_date', { ascending: true })

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-6 text-center text-2xl font-semibold">Modo de estudo</h1>
      <StudySession cards={flashcards ?? []} />
    </div>
  )
}
