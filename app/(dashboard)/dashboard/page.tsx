import Link from 'next/link'
import { AlertTriangle, ArrowRight, BarChart3, CheckCircle2, ListChecks, TrendingUp } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { StatCard } from '@/components/shared/stat-card'
import { EmptyState } from '@/components/shared/empty-state'
import { LineAccuracyChart } from '@/components/graficos/line-accuracy-chart'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { Button } from '@/components/ui/button'
import {
  computeAccuracyOverTime,
  computeFocusAreas,
  computeSubjectPerformance,
  computeSummaryCards,
  computeTagPerformance,
} from '@/lib/utils/metrics'
import { formatPercent } from '@/lib/utils/format'

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
      supabase.from('exam_sessions').select('id, score, finished_at, mode').order('finished_at', { ascending: true }),
    ])

  const answersData = answers ?? []
  const sessionsData = sessions ?? []

  const accuracyOverTime = computeAccuracyOverTime(sessionsData)
  const subjectPerformance = computeSubjectPerformance(answersData, questions ?? [], subjects ?? [])
  const tagPerformance = computeTagPerformance(answersData, questionTags ?? [], tags ?? [])
  const summary = computeSummaryCards(sessionsData, answersData, subjectPerformance, tagPerformance)
  const focusAreas = computeFocusAreas(subjectPerformance, tagPerformance, 5)

  const hasData = sessionsData.some((s) => s.finished_at)
  const firstName = (user?.user_metadata?.full_name as string | undefined)?.split(' ')[0]

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">Olá{firstName ? `, ${firstName}` : ''} 👋</h1>
          <p className="text-sm text-muted-foreground">Aqui está um resumo do seu desempenho.</p>
        </div>
        <Button asChild>
          <Link href="/simulado">
            Novo simulado <ArrowRight className="h-4 w-4" />
          </Link>
        </Button>
      </div>

      {!hasData ? (
        <EmptyState
          icon={ListChecks}
          title="Você ainda não finalizou nenhum simulado"
          description="Cadastre questões e comece seu primeiro simulado para ver suas estatísticas aqui."
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

          <div className="flex justify-end">
            <Button asChild variant="outline">
              <Link href="/progresso">
                Ver análise completa <ArrowRight className="h-4 w-4" />
              </Link>
            </Button>
          </div>
        </>
      )}
    </div>
  )
}
