import { BarChart3 } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Badge } from '@/components/ui/badge'
import { EmptyState } from '@/components/shared/empty-state'
import { LineAccuracyChart } from '@/components/graficos/line-accuracy-chart'
import { BarSubjectChart } from '@/components/graficos/bar-subject-chart'
import { BarTagChart } from '@/components/graficos/bar-tag-chart'
import { PieSessionChart } from '@/components/graficos/pie-session-chart'
import {
  computeAccuracyOverTime,
  computeLastSessionBreakdown,
  computeSubjectPerformance,
  computeTagPerformance,
} from '@/lib/utils/metrics'
import { formatDateTime, formatPercent, MODE_LABELS } from '@/lib/utils/format'

export default async function ProgressoPage() {
  const supabase = createClient()

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

  if (finishedSessions.length === 0) {
    return (
      <EmptyState
        icon={BarChart3}
        title="Ainda não há dados de progresso"
        description="Finalize pelo menos um simulado para desbloquear os gráficos de desempenho."
      />
    )
  }

  const accuracyOverTime = computeAccuracyOverTime(sessionsData)
  const subjectPerformance = computeSubjectPerformance(answersData, questions ?? [], subjects ?? [])
  const tagPerformance = computeTagPerformance(answersData, questionTags ?? [], tags ?? [])
  const lastSession = computeLastSessionBreakdown(sessionsData, answersData)

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">Progresso</h1>
        <p className="text-sm text-muted-foreground">Análise completa do seu desempenho ao longo do tempo.</p>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Evolução do % de acerto</CardTitle>
          </CardHeader>
          <CardContent>
            <LineAccuracyChart data={accuracyOverTime} />
          </CardContent>
        </Card>

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
    </div>
  )
}
