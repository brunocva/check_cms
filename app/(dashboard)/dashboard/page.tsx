import Link from 'next/link'
import { AlertTriangle, ArrowRight, BarChart3, CheckCircle2, ListChecks, TrendingUp } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { StatCard } from '@/components/shared/stat-card'
import { EmptyState } from '@/components/shared/empty-state'
import { LineAccuracyChart } from '@/components/graficos/line-accuracy-chart'
import { BarSubjectChart } from '@/components/graficos/bar-subject-chart'
import { BarTagChart } from '@/components/graficos/bar-tag-chart'
import { PieSessionChart } from '@/components/graficos/pie-session-chart'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { Button } from '@/components/ui/button'
import {
  computeAccuracyOverTime,
  computeFocusAreas,
  computeLastSessionBreakdown,
  computeSubjectPerformance,
  computeSummaryCards,
  computeTagPerformance,
} from '@/lib/utils/metrics'
import { formatDateTime, formatPercent, MODE_LABELS } from '@/lib/utils/format'

// Página única de desempenho: resumo rápido (KPIs + onde focar) no topo,
// seguido da análise completa (gráficos por matéria/tag, última sessão e
// histórico) — antes eram duas páginas (Dashboard e Progresso) com o mesmo
// gráfico de evolução duplicado entre elas.
export default async function DashboardPage() {
  const supabase = createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  // Busca tudo em paralelo — as tabelas são pequenas (uso pessoal), então
  // agregamos em JS em vez de escrever SQL com múltiplos joins aninhados
  // (ver comentário em lib/utils/metrics.ts).
  const [{ data: subjects }, { data: tags }, { data: questions }, { data: questionTags }, { data: answers }, { data: sessions }] =
    await Promise.all([
      supabase.from('subjects').select('id, name'),
      supabase.from('tags').select('id, name, color'),
      supabase.from('questions').select('id, subject_id'),
      supabase.from('question_tags').select('question_id, tag_id'),
      supabase.from('answers').select('id, question_id, session_id, is_correct'),
      supabase
        .from('exam_sessions')
        .select('id, score, finished_at, mode, total_questions, correct_count')
        .order('finished_at', { ascending: false }),
    ])

  const answersData = answers ?? []
  const sessionsData = sessions ?? []
  const finishedSessions = sessionsData.filter((s) => s.finished_at)

  const accuracyOverTime = computeAccuracyOverTime(sessionsData)
  const subjectPerformance = computeSubjectPerformance(answersData, questions ?? [], subjects ?? [])
  const tagPerformance = computeTagPerformance(answersData, questionTags ?? [], tags ?? [])
  const summary = computeSummaryCards(sessionsData, answersData, subjectPerformance, tagPerformance)
  const focusAreas = computeFocusAreas(subjectPerformance, tagPerformance, 5)
  const lastSession = computeLastSessionBreakdown(sessionsData, answersData)

  const hasData = finishedSessions.length > 0
  const firstName = (user?.user_metadata?.full_name as string | undefined)?.split(' ')[0]

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">Olá{firstName ? `, ${firstName}` : ''} 👋</h1>
          <p className="text-sm text-muted-foreground">Aqui está um resumo do seu desempenho.</p>
        </div>
        {!hasData && (
          <Button asChild>
            <Link href="/simulado">
              Novo simulado <ArrowRight className="h-4 w-4" />
            </Link>
          </Button>
        )}
      </div>

      {!hasData ? (
        <EmptyState
          icon={ListChecks}
          title="Você ainda não finalizou nenhum simulado"
          description="Comece seu primeiro simulado para ver suas estatísticas aqui."
          action={
            <Button asChild>
              <Link href="/simulado">Começar agora</Link>
            </Button>
          }
        />
      ) : (
        <>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <StatCard title="Questões respondidas" value={summary.totalAnswered} icon={ListChecks} />
            <StatCard title="Média de acerto" value={formatPercent(summary.averageScore)} icon={TrendingUp} />
            <StatCard
              title="Melhor matéria"
              value={summary.bestSubject?.name ?? '—'}
              subtitle={summary.bestSubject ? formatPercent(summary.bestSubject.accuracy) : undefined}
              icon={CheckCircle2}
            />
            <StatCard
              title="Tag com maior déficit"
              value={summary.worstTag?.name ?? '—'}
              subtitle={summary.worstTag ? formatPercent(summary.worstTag.accuracy) : undefined}
              icon={AlertTriangle}
            />
          </div>

          <div className="grid gap-4 lg:grid-cols-3">
            <Card className="lg:col-span-2">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-base">
                  <TrendingUp className="h-4 w-4" /> Evolução do % de acerto
                </CardTitle>
              </CardHeader>
              <CardContent>
                <LineAccuracyChart data={accuracyOverTime} />
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-base">
                  <BarChart3 className="h-4 w-4" /> Onde focar
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                {focusAreas.length === 0 && <p className="text-sm text-muted-foreground">Sem dados suficientes ainda.</p>}
                {focusAreas.map((area) => (
                  <div key={`${area.kind}-${area.id}`} className="space-y-1">
                    <div className="flex items-center justify-between text-sm">
                      <span className="font-medium">{area.name}</span>
                      <span className="text-muted-foreground">{formatPercent(area.accuracy)}</span>
                    </div>
                    <Progress
                      value={area.accuracy}
                      indicatorClassName={area.accuracy < 50 ? 'bg-destructive' : area.accuracy < 75 ? 'bg-amber-500' : 'bg-success'}
                    />
                    <p className="text-xs capitalize text-muted-foreground">{area.kind === 'materia' ? 'Matéria' : 'Tag'}</p>
                  </div>
                ))}
              </CardContent>
            </Card>
          </div>

          <div className="grid gap-4 lg:grid-cols-3">
            {lastSession && (
              <Card>
                <CardHeader>
                  <CardTitle className="text-base">Última sessão: acertos x erros</CardTitle>
                </CardHeader>
                <CardContent>
                  <PieSessionChart data={lastSession.data} />
                </CardContent>
              </Card>
            )}

            <Card>
              <CardHeader>
                <CardTitle className="text-base">Desempenho por matéria</CardTitle>
              </CardHeader>
              <CardContent>
                {subjectPerformance.length > 0 ? (
                  <BarSubjectChart data={subjectPerformance} />
                ) : (
                  <p className="text-sm text-muted-foreground">Sem dados.</p>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-base">Desempenho por tag</CardTitle>
              </CardHeader>
              <CardContent>
                {tagPerformance.length > 0 ? (
                  <BarTagChart data={tagPerformance} />
                ) : (
                  <p className="text-sm text-muted-foreground">Sem dados.</p>
                )}
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle className="text-base">Histórico de simulados</CardTitle>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Data</TableHead>
                    <TableHead>Modo</TableHead>
                    <TableHead>Acertos</TableHead>
                    <TableHead>Aproveitamento</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {finishedSessions.map((session) => (
                    <TableRow key={session.id}>
                      <TableCell>{formatDateTime(session.finished_at)}</TableCell>
                      <TableCell>
                        <Badge variant="outline">{MODE_LABELS[session.mode]}</Badge>
                      </TableCell>
                      <TableCell>
                        {session.correct_count}/{session.total_questions}
                      </TableCell>
                      <TableCell>{formatPercent(session.score)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </>
      )}
    </div>
  )
}
