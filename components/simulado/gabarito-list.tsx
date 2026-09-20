import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { cn } from '@/lib/utils'
import type { QuestionOption } from '@/lib/types'

export interface GabaritoItem {
  questionId: string
  statement: string
  options: QuestionOption[]
  correctOption: string
  explanation: string | null
  selectedOption: string
  isCorrect: boolean
}

export function GabaritoList({ items }: { items: GabaritoItem[] }) {
  return (
    <div className="space-y-4">
      {items.map((item, index) => (
        <Card key={item.questionId}>
          <CardContent className="space-y-3 pt-6">
            <div className="flex items-start justify-between gap-3">
              <p className="text-sm font-medium leading-relaxed">
                {index + 1}. {item.statement}
              </p>
              <Badge variant={item.isCorrect ? 'success' : 'destructive'} className="shrink-0">
                {item.isCorrect ? 'Correta' : 'Errada'}
              </Badge>
            </div>

            <div className="space-y-1.5">
              {item.options.map((option) => {
                const isCorrectOption = option.key === item.correctOption
                const isSelected = option.key === item.selectedOption
                return (
                  <div
                    key={option.key}
                    className={cn(
                      'flex items-start gap-2 rounded-md border p-2 text-sm',
                      isCorrectOption && 'border-success bg-success/10',
                      isSelected && !isCorrectOption && 'border-destructive bg-destructive/10'
                    )}
                  >
                    <span className="font-semibold">{option.key})</span>
                    <span>{option.text}</span>
                    {isSelected && <span className="ml-auto shrink-0 text-xs text-muted-foreground">sua resposta</span>}
                  </div>
                )
              })}
            </div>

            {item.explanation && (
              <p className="rounded-md bg-muted p-3 text-sm text-muted-foreground">
                <span className="font-medium text-foreground">Explicação: </span>
                {item.explanation}
              </p>
            )}
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
