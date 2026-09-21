import Link from 'next/link'
import { ListChecks, Plus } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { SubjectManager } from '@/components/questoes/subject-manager'
import { TagManager } from '@/components/tags/tag-manager'
import { QuestionFilters } from '@/components/questoes/question-filters'
import { QuestionPagination } from '@/components/questoes/question-pagination'
import { QuestionPracticeCard } from '@/components/questoes/question-practice-card'
import { Button } from '@/components/ui/button'
import { EmptyState } from '@/components/shared/empty-state'
import type { Difficulty, Tag } from '@/lib/types'

const PAGE_SIZE = 10

export default async function QuestoesPage({
  searchParams,
}: {
  searchParams: { subject?: string; tag?: string; difficulty?: string; page?: string }
}) {
  const supabase = createClient()

  const [{ data: subjects }, { data: tags }] = await Promise.all([
    supabase.from('subjects').select('*').order('name'),
    supabase.from('tags').select('*').order('name'),
  ])

  let query = supabase
    .from('questions')
    .select('id, statement, subject_id, difficulty, options, correct_option, explanation, created_at')
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

  // Paginação: 10 questões por página, aplicada depois dos filtros.
  const totalPages = Math.max(1, Math.ceil(filteredQuestions.length / PAGE_SIZE))
  const currentPage = Math.min(Math.max(1, Number(searchParams.page) || 1), totalPages)
  const pageQuestions = filteredQuestions.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE)

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">Questões</h1>
          <p className="text-sm text-muted-foreground">
            Modo prática: filtre, responda e veja na hora se acertou. Para uma prova cronometrada, use o Simulado.
          </p>
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

      {pageQuestions.length === 0 ? (
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
        <>
          <div className="space-y-3">
            {pageQuestions.map((question) => {
              const questionTagList: Tag[] = (tagIdsByQuestion.get(question.id) ?? [])
                .map((id) => tagsById.get(id))
                .filter((t): t is Tag => Boolean(t))
              const subject = question.subject_id ? subjectsById.get(question.subject_id) : null

              return (
                <QuestionPracticeCard
                  key={question.id}
                  question={{
                    id: question.id,
                    statement: question.statement,
                    options: question.options,
                    correctOption: question.correct_option,
                    explanation: question.explanation,
                    difficulty: question.difficulty,
                  }}
                  subjectName={subject?.name ?? null}
                  tags={questionTagList}
                />
              )
            })}
          </div>

          <QuestionPagination currentPage={currentPage} totalPages={totalPages} />
        </>
      )}
    </div>
  )
}
