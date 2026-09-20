// Cálculo de métricas do dashboard/progresso.
//
// Decisão de design: em vez de escrever queries SQL/PostgREST com embeds
// aninhados (answers -> questions -> subjects / question_tags -> tags),
// buscamos as tabelas separadamente (poucas linhas, uso pessoal) e agregamos
// aqui em memória. Isso deixa a lógica de negócio 100% testável em TS puro e
// fácil de ler, ao custo de mais round-trips — irrelevante na escala de um
// projeto pessoal.

export interface SessionRow {
  id: string
  score: number
  finished_at: string | null
  mode: string
}

export interface AnswerRow {
  id: string
  question_id: string
  session_id: string
  is_correct: boolean
}

export interface QuestionRow {
  id: string
  subject_id: string | null
}

export interface SubjectRow {
  id: string
  name: string
}

export interface QuestionTagRow {
  question_id: string
  tag_id: string
}

export interface TagRow {
  id: string
  name: string
  color: string
}

export interface PerformanceEntry {
  id: string
  name: string
  color?: string
  total: number
  correct: number
  accuracy: number // 0-100
}

export interface AccuracyPoint {
  sessionId: string
  date: string
  score: number
}

/** Série temporal do % de acerto, uma sessão finalizada por ponto. */
export function computeAccuracyOverTime(sessions: SessionRow[]): AccuracyPoint[] {
  return sessions
    .filter((s) => s.finished_at)
    .sort((a, b) => new Date(a.finished_at!).getTime() - new Date(b.finished_at!).getTime())
    .map((s) => ({ sessionId: s.id, date: s.finished_at!, score: s.score }))
}

function buildQuestionSubjectMap(questions: QuestionRow[]) {
  const map = new Map<string, string | null>()
  for (const q of questions) map.set(q.id, q.subject_id)
  return map
}

function buildQuestionTagsMap(questionTags: QuestionTagRow[]) {
  const map = new Map<string, string[]>()
  for (const qt of questionTags) {
    const list = map.get(qt.question_id) ?? []
    list.push(qt.tag_id)
    map.set(qt.question_id, list)
  }
  return map
}

/** Desempenho (acertos/total/%) agrupado por matéria. */
export function computeSubjectPerformance(
  answers: AnswerRow[],
  questions: QuestionRow[],
  subjects: SubjectRow[]
): PerformanceEntry[] {
  const questionSubject = buildQuestionSubjectMap(questions)
  const bucket = new Map<string, { total: number; correct: number }>()

  for (const answer of answers) {
    const subjectId = questionSubject.get(answer.question_id)
    if (!subjectId) continue
    const entry = bucket.get(subjectId) ?? { total: 0, correct: 0 }
    entry.total += 1
    if (answer.is_correct) entry.correct += 1
    bucket.set(subjectId, entry)
  }

  return subjects
    .filter((s) => bucket.has(s.id))
    .map((s) => {
      const { total, correct } = bucket.get(s.id)!
      return { id: s.id, name: s.name, total, correct, accuracy: percentage(correct, total) }
    })
    .sort((a, b) => b.total - a.total)
}

/** Desempenho (acertos/total/%) agrupado por tag. Uma resposta pode contar
 * para várias tags, pois uma questão pode ter N tags. */
export function computeTagPerformance(
  answers: AnswerRow[],
  questionTags: QuestionTagRow[],
  tags: TagRow[]
): PerformanceEntry[] {
  const questionTagIds = buildQuestionTagsMap(questionTags)
  const bucket = new Map<string, { total: number; correct: number }>()

  for (const answer of answers) {
    const tagIds = questionTagIds.get(answer.question_id) ?? []
    for (const tagId of tagIds) {
      const entry = bucket.get(tagId) ?? { total: 0, correct: 0 }
      entry.total += 1
      if (answer.is_correct) entry.correct += 1
      bucket.set(tagId, entry)
    }
  }

  return tags
    .filter((t) => bucket.has(t.id))
    .map((t) => {
      const { total, correct } = bucket.get(t.id)!
      return { id: t.id, name: t.name, color: t.color, total, correct, accuracy: percentage(correct, total) }
    })
    .sort((a, b) => b.total - a.total)
}

/** Acertos x erros da última sessão finalizada (para o gráfico de pizza). */
export function computeLastSessionBreakdown(sessions: SessionRow[], answers: AnswerRow[]) {
  const finished = sessions.filter((s) => s.finished_at).sort((a, b) => new Date(b.finished_at!).getTime() - new Date(a.finished_at!).getTime())
  const last = finished[0]
  if (!last) return null

  const sessionAnswers = answers.filter((a) => a.session_id === last.id)
  const correct = sessionAnswers.filter((a) => a.is_correct).length
  const total = sessionAnswers.length

  return {
    session: last,
    data: [
      { name: 'Acertos', value: correct },
      { name: 'Erros', value: total - correct },
    ],
  }
}

export interface SummaryCards {
  totalAnswered: number
  averageScore: number
  bestSubject: PerformanceEntry | null
  worstSubject: PerformanceEntry | null
  worstTag: PerformanceEntry | null
}

export function computeSummaryCards(
  sessions: SessionRow[],
  answers: AnswerRow[],
  subjectPerformance: PerformanceEntry[],
  tagPerformance: PerformanceEntry[]
): SummaryCards {
  const finishedSessions = sessions.filter((s) => s.finished_at)
  const averageScore = finishedSessions.length
    ? finishedSessions.reduce((sum, s) => sum + s.score, 0) / finishedSessions.length
    : 0

  const sortedSubjects = [...subjectPerformance].sort((a, b) => b.accuracy - a.accuracy)
  const sortedTags = [...tagPerformance].sort((a, b) => a.accuracy - b.accuracy)

  return {
    totalAnswered: answers.length,
    averageScore,
    bestSubject: sortedSubjects[0] ?? null,
    worstSubject: sortedSubjects[sortedSubjects.length - 1] ?? null,
    worstTag: sortedTags[0] ?? null,
  }
}

export interface FocusArea extends PerformanceEntry {
  kind: 'materia' | 'tag'
}

/** Matérias + tags ordenadas pela menor % de acerto — "onde focar". */
export function computeFocusAreas(
  subjectPerformance: PerformanceEntry[],
  tagPerformance: PerformanceEntry[],
  limit = 5
): FocusArea[] {
  const merged: FocusArea[] = [
    ...subjectPerformance.map((s) => ({ ...s, kind: 'materia' as const })),
    ...tagPerformance.map((t) => ({ ...t, kind: 'tag' as const })),
  ]

  return merged.sort((a, b) => a.accuracy - b.accuracy).slice(0, limit)
}

function percentage(part: number, total: number) {
  if (total === 0) return 0
  return Math.round((part / total) * 1000) / 10 // 1 casa decimal
}
