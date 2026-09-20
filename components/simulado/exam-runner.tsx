'use client'

import { useState, useTransition } from 'react'
import { toast } from 'sonner'
import { finishExamSession } from '@/lib/actions/exam'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { cn } from '@/lib/utils'
import type { QuestionOption } from '@/lib/types'

interface RunnerQuestion {
  id: string
  statement: string
  options: QuestionOption[]
}

export function ExamRunner({ sessionId, questions }: { sessionId: string; questions: RunnerQuestion[] }) {
  const [index, setIndex] = useState(0)
  const [answers, setAnswers] = useState<Record<string, string>>({})
  const [isPending, startTransition] = useTransition()

  const current = questions[index]
  const isLast = index === questions.length - 1
  const answeredCount = Object.keys(answers).length

  function selectOption(key: string) {
    setAnswers((prev) => ({ ...prev, [current.id]: key }))
  }

  function goNext() {
    if (!isLast) setIndex((i) => i + 1)
  }

  function goPrev() {
    if (index > 0) setIndex((i) => i - 1)
  }

  function handleFinish() {
    startTransition(async () => {
      const result = await finishExamSession({
        sessionId,
        answers: Object.entries(answers).map(([questionId, selectedOption]) => ({ questionId, selectedOption })),
      })
      if (result?.error) toast.error(result.error)
      // Sucesso redireciona para /simulado/[sessionId]/resultado dentro da action.
    })
  }

  if (!current) return null

  return (
    <div className="space-y-6">
      <div className="space-y-2">
        <div className="flex items-center justify-between text-sm text-muted-foreground">
          <span>
            Questão {index + 1} de {questions.length}
          </span>
          <span>{answeredCount} respondida(s)</span>
        </div>
        <Progress value={((index + 1) / questions.length) * 100} />
      </div>

      <div className="rounded-xl border p-6">
        <p className="mb-4 text-base font-medium leading-relaxed">{current.statement}</p>
        <div className="space-y-2">
          {current.options.map((option) => {
            const selected = answers[current.id] === option.key
            return (
              <button
                type="button"
                key={option.key}
                onClick={() => selectOption(option.key)}
                className={cn(
                  'flex w-full items-start gap-3 rounded-lg border p-3 text-left text-sm transition-colors',
                  selected ? 'border-primary bg-primary/10' : 'hover:bg-accent'
                )}
              >
                <span className="font-semibold">{option.key})</span>
                <span>{option.text}</span>
              </button>
            )
          })}
        </div>
      </div>

      <div className="flex items-center justify-between">
        <Button type="button" variant="outline" onClick={goPrev} disabled={index === 0}>
          Anterior
        </Button>

        {isLast ? (
          <Button type="button" onClick={handleFinish} disabled={isPending || answeredCount === 0}>
            {isPending ? 'Enviando...' : 'Finalizar simulado'}
          </Button>
        ) : (
          <Button type="button" onClick={goNext}>
            Próxima
          </Button>
        )}
      </div>
    </div>
  )
}
