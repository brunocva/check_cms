import Link from 'next/link'
import { ListChecks, Pencil, Plus, Sparkles } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { SubjectManager } from '@/components/questoes/subject-manager'
import { TagManager } from '@/components/tags/tag-manager'
import { QuestionFilters } from '@/components/questoes/question-filters'
import { DeleteQuestionButton } from '@/components/questoes/delete-question-button'
import { TagBadge } from '@/components/tags/tag-badge'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { EmptyState } from '@/components/shared/empty-state'
import { createFlashcardFromQuestion } from '@/lib/actions/flashcards'
import { DIFFICULTY_LABELS } from '@/lib/utils/format'
import type { Difficulty, Tag } from '@/lib/types'

export default async function QuestoesPage({
  searchParams,
}: {
  searchParams: { subject?: string; tag?: string; difficulty?: string }
}) {
  const supabase = createClient()

  const [{ data: subjects }, { data: tags }] = await Promise.all([
    supabase.from('subjects').select('*').order('name'),
    supabase.from('tags').select('*').order('name'),
  ])

  let query = supabase
    .from('questions')
    .select('id, statement, subject_id, difficulty, created_at')
    .order('created_at', { ascending: false })

  if (searchParams.subject) query = query.eq('subject_id', searchParams.subject)
  if (searchParams.difficulty) query = query.eq('difficulty', searchParams.difficulty as Difficulty)

  const { data: questions } = await query

  const questionIds = (questions ?? []).map((q) => q.id)
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

  // Filtro por tag é aplicado em memória, pois depende da tabela N:N.
  let filteredQuestions = questions ?? []
  if (searchParams.tag) {
    const tagFilter = searchParams.tag
    filteredQuestions = filteredQuestions.filter((q) => (tagIdsByQuestion.get(q.id) ?? []).includes(tagFilter))
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">Questões</h1>
          <p className="text-sm text-muted-foreground">Seu banco de questões de múltipla escolha.</p>
        </div>
        <Button asChild>
          <Link href="/questoes/nova">
            <Plus className="h-4 w-4" /> Nova questão
          </Link>
        </Button>
      </div>

      <details className="rounded-lg border p-4">
        <summary className="cursor-pointer text-sm font-medium">Gerenciar matérias e tags</summary>
        <div className="mt-4 space-y-6">
          <div>
            <p className="mb-2 text-xs font-semibold uppercase text-muted-foreground">Matérias</p>
            <SubjectManager subjects={subjects ?? []} />
          </div>
          <div>
            <p className="mb-2 text-xs font-semibold uppercase text-muted-foreground">Tags</p>
            <TagManager tags={tags ?? []} />
          </div>
        </div>
      </details>

      <QuestionFilters subjects={subjects ?? []} tags={tags ?? []} />

      {filteredQuestions.length === 0 ? (
        <EmptyState
          icon={ListChecks}
          title="Nenhuma questão encontrada"
          description="Ajuste os filtros ou cadastre sua primeira questão."
          action={
            <Button asChild>
              <Link href="/questoes/nova">Nova questão</Link>
            </Button>
          }
        />
      ) : (
        <div className="space-y-3">
          {filteredQuestions.map((question) => {
            const questionTagList: Tag[] = (tagIdsByQuestion.get(question.id) ?? [])
              .map((id) => tagsById.get(id))
              .filter((t): t is Tag => Boolean(t))
            const subject = question.subject_id ? subjectsById.get(question.subject_id) : null

            return (
              <Card key={question.id}>
                <CardContent className="flex flex-col gap-3 pt-6 sm:flex-row sm:items-start sm:justify-between">
                  <div className="space-y-2">
                    <p className="text-sm font-medium leading-relaxed">{question.statement}</p>
                    <div className="flex flex-wrap items-center gap-1.5">
                      {subject && <Badge variant="outline">{subject.name}</Badge>}
                      <Badge variant="secondary">{DIFFICULTY_LABELS[question.difficulty]}</Badge>
                      {questionTagList.map((tag) => (
                        <TagBadge key={tag.id} tag={tag} />
                      ))}
                    </div>
                  </div>
                  <div className="flex shrink-0 items-center gap-1">
                    <form action={createFlashcardFromQuestion}>
                      <input type="hidden" name="questionId" value={question.id} />
                      <Button type="submit" variant="ghost" size="icon" aria-label="Criar flashcard desta questão">
                        <Sparkles className="h-4 w-4" />
                      </Button>
                    </form>
                    <Button asChild variant="ghost" size="icon" aria-label="Editar questão">
                      <Link href={`/questoes/${question.id}/editar`}>
                        <Pencil className="h-4 w-4" />
                      </Link>
                    </Button>
                    <DeleteQuestionButton id={question.id} />
                  </div>
                </CardContent>
              </Card>
            )
          })}
        </div>
      )}
    </div>
  )
}
