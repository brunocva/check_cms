'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Pencil, Sparkles } from 'lucide-react'
import { createFlashcardFromQuestion } from '@/lib/actions/flashcards'
import { DeleteQuestionButton } from '@/components/questoes/delete-question-button'
import { TagBadge } from '@/components/tags/tag-badge'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { DIFFICULTY_LABELS } from '@/lib/utils/format'
import { cn } from '@/lib/utils'
import type { Difficulty, QuestionOption, Tag } from '@/lib/types'

interface PracticeQuestion {
  id: string
  statement: string
  options: QuestionOption[]
  correctOption: string
  explanation: string | null
  difficulty: Difficulty
}

// Card de "modo prática": ao clicar em uma alternativa, revela na hora se
// acertou ou errou (cores verde/vermelha) e mostra a explicação. Diferente
// do Simulado, aqui o feedback é imediato e não fica registrado como uma
// sessão de prova (não conta para as métricas do dashboard).
export function QuestionPracticeCard({
  question,
  subjectName,
  tags,
  isAdmin,
}: {
  question: PracticeQuestion
  subjectName: string | null
  tags: Tag[]
  isAdmin: boolean
}) {
  const [selected, setSelected] = useState<string | null>(null)
  const isAnswered = selected !== null
  const isCorrect = selected === question.correctOption

  return (
    <Card>
      <CardContent className="space-y-3 pt-6">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div className="space-y-2">
            <p className="text-sm font-medium leading-relaxed">{question.statement}</p>
            <div className="flex flex-wrap items-center gap-1.5">
              {subjectName && <Badge variant="outline">{subjectName}</Badge>}
              <Badge variant="secondary">{DIFFICULTY_LABELS[question.difficulty]}</Badge>
              {tags.map((tag) => (
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
            {isAdmin && (
              <>
                <Button asChild variant="ghost" size="icon" aria-label="Editar questão">
                  <Link href={`/questoes/${question.id}/editar`}>
                    <Pencil className="h-4 w-4" />
                  </Link>
                </Button>
                <DeleteQuestionButton id={question.id} />
              </>
            )}
          </div>
        </div>

        <div className="space-y-2">
          {question.options.map((option) => {
            const isSelected = selected === option.key
            const isRightAnswer = option.key === question.correctOption

            return (
              <button
                type="button"
                key={option.key}
                disabled={isAnswered}
                onClick={() => setSelected(option.key)}
                className={cn(
                  'flex w-full items-start gap-3 rounded-lg border p-3 text-left text-sm transition-colors',
                  !isAnswered && 'hover:bg-accent',
                  isAnswered && isRightAnswer && 'border-green-600 bg-green-600/10',
                  isAnswered && isSelected && !isRightAnswer && 'border-red-600 bg-red-600/10',
                  isAnswered && !isSelected && !isRightAnswer && 'opacity-60'
                )}
              >
                <span className="font-semibold">{option.key})</span>
                <span>{option.text}</span>
              </button>
            )
          })}
        </div>

        {isAnswered && (
          <div
            className={cn(
              'rounded-lg border p-3 text-sm',
              isCorrect ? 'border-green-600/50 bg-green-600/5' : 'border-red-600/50 bg-red-600/5'
            )}
          >
            <p className="font-medium">{isCorrect ? 'Você acertou!' : 'Você errou.'}</p>
            {!isCorrect && <p className="mt-1">Resposta correta: {question.correctOption}</p>}
            {question.explanation && <p className="mt-1 text-muted-foreground">{question.explanation}</p>}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
