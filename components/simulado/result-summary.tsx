import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { PieSessionChart } from '@/components/graficos/pie-session-chart'
import { formatPercent } from '@/lib/utils/format'

export function ResultSummary({ correct, total, score }: { correct: number; total: number; score: number }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Resultado</CardTitle>
      </CardHeader>
      <CardContent className="grid gap-6 sm:grid-cols-2 sm:items-center">
        <div className="space-y-1">
          <p className="text-4xl font-bold">{formatPercent(score)}</p>
          <p className="text-sm text-muted-foreground">
            {correct} de {total} questões corretas
          </p>
        </div>
        <PieSessionChart
          data={[
            { name: 'Acertos', value: correct },
            { name: 'Erros', value: total - correct },
          ]}
        />
      </CardContent>
    </Card>
  )
}
