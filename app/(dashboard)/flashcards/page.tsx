import Link from 'next/link'
import { Sparkles } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { NewFlashcardToggle } from '@/components/flashcards/new-flashcard-toggle'
import { FlashcardFilters } from '@/components/flashcards/flashcard-filters'
import { FlashcardList, type FlashcardListItem } from '@/components/flashcards/flashcard-list'
import { EmptyState } from '@/components/shared/empty-state'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { FLASHCARD_STATUS_LABELS } from '@/lib/utils/format'
import { isDueToday } from '@/lib/sm2'
import type { FlashcardStatus, Tag } from '@/lib/types'

export default async function FlashcardsPage({
  searchParams,
}: {
  searchParams: { subject?: string; tag?: string; status?: string }
}) {
  const supabase = createClient()

  const [{ data: subjects }, { data: tags }] = await Promise.all([
    supabase.from('subjects').select('*').order('name'),
    supabase.from('tags').select('*').order('name'),
  ])

  let query = supabase
    .from('flashcards')
    .select('id, front, subject_id, question_id, status, next_review_date')
    .order('created_at', { ascending: false })

  if (searchParams.subject) query = query.eq('subject_id', searchParams.subject)
  if (searchParams.status) query = query.eq('status', searchParams.status as FlashcardStatus)

  const { data: flashcards } = await query

  // Tags de um flashcard vêm da questão de origem (question_id ->
  // question_tags -> tags). Cartões criados manualmente não têm tags.
  const questionIds = (flashcards ?? []).map((f) => f.question_id).filter((id): id is string => Boolean(id))
  const { data: questionTags } = questionIds.length
    ? await supabase.from('question_tags').select('question_id, tag_id').in('question_id', questionIds)
    : { data: [] as { question_id: string; tag_id: string }[] }

  const tagsById = new Map((tags ?? []).map((t) => [t.id, t]))
  const subjectsById = new Map((subjects ?? []).map((s) => [s.id, s]))
  const tagIdsByQuestion = new Map<string, string[]>()
  for (const qt of questionTags ?? []) {
    const list = tagIdsByQuestion.get(qt.question_id) ?? []
    list.push(qt.tag_id)
    tagIdsByQuestion.set(qt.question_id, list)
  }

  let filtered = flashcards ?? []
  if (searchParams.tag) {
    const tagFilter = searchParams.tag
    filtered = filtered.filter((f) => f.question_id && (tagIdsByQuestion.get(f.question_id) ?? []).includes(tagFilter))
  }

  const items: FlashcardListItem[] = filtered.map((f) => ({
    id: f.id,
    front: f.front,
    status: f.status,
    subjectName: f.subject_id ? subjectsById.get(f.subject_id)?.name ?? null : null,
    tags: f.question_id
      ? (tagIdsByQuestion.get(f.question_id) ?? []).map((id) => tagsById.get(id)).filter((t): t is Tag => Boolean(t))
      : [],
    nextReviewDate: f.next_review_date,
  }))

  const dueCount = (flashcards ?? []).filter((f) => isDueToday(f.next_review_date)).length
  const counts = {
    novo: (flashcards ?? []).filter((f) => f.status === 'novo').length,
    revisando: (flashcards ?? []).filter((f) => f.status === 'revisando').length,
    dominado: (flashcards ?? []).filter((f) => f.status === 'dominado').length,
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">Flashcards</h1>
          <p className="text-sm text-muted-foreground">Revise com repetição espaçada.</p>
        </div>
        <Button asChild size="lg">
          <Link href="/flashcards/estudar">
            <Sparkles className="h-4 w-4" /> Estudar agora ({dueCount})
          </Link>
        </Button>
      </div>

      <div className="flex flex-wrap gap-2">
        <Badge variant="secondary">
          {FLASHCARD_STATUS_LABELS.novo}: {counts.novo}
        </Badge>
        <Badge>
          {FLASHCARD_STATUS_LABELS.revisando}: {counts.revisando}
        </Badge>
        <Badge variant="success">
          {FLASHCARD_STATUS_LABELS.dominado}: {counts.dominado}
        </Badge>
      </div>

      <NewFlashcardToggle subjects={subjects ?? []} />

      <FlashcardFilters subjects={subjects ?? []} tags={tags ?? []} />

      {items.length === 0 ? (
        <EmptyState
          icon={Sparkles}
          title="Nenhum flashcard encontrado"
          description="Crie flashcards manualmente ou gere a partir de questões erradas em um simulado."
        />
      ) : (
        <FlashcardList items={items} />
      )}
    </div>
  )
}
