'use client'

import { useState, useTransition } from 'react'
import Link from 'next/link'
import { toast } from 'sonner'
import { reviewFlashcard } from '@/lib/actions/flashcards'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { RATING_LABELS } from '@/lib/utils/format'
import type { FlashcardRating } from '@/lib/types'

const RATINGS: { key: FlashcardRating; className: string }[] = [
  { key: 'errei', className: 'bg-red-500 text-white hover:bg-red-600' },
  { key: 'dificil', className: 'bg-orange-500 text-white hover:bg-orange-600' },
  { key: 'bom', className: 'bg-blue-500 text-white hover:bg-blue-600' },
  { key: 'facil', className: 'bg-green-600 text-white hover:bg-green-700' },
]

interface StudyCard {
  id: string
  front: string
  back: string
}

export function StudySession({ cards }: { cards: StudyCard[] }) {
  const [index, setIndex] = useState(0)
  const [flipped, setFlipped] = useState(false)
  const [reviewed, setReviewed] = useState(0)
  const [isPending, startTransition] = useTransition()

  const current = cards[index]

  function handleRate(rating: FlashcardRating) {
    if (!current) return
    startTransition(async () => {
      const result = await reviewFlashcard({ flashcardId: current.id, rating })
      if (result.error) {
        toast.error(result.error)
        return
      }
      setReviewed((r) => r + 1)
      setFlipped(false)
      setIndex((i) => i + 1)
    })
  }

  if (!current) {
    return (
      <div className="space-y-3 rounded-xl border border-dashed p-10 text-center">
        <p className="text-lg font-semibold">
          {reviewed > 0 ? `Você revisou ${reviewed} cartão(ões)! 🎉` : 'Nenhum cartão para revisar agora. 🎉'}
        </p>
        <Button asChild>
          <Link href="/flashcards">Voltar para flashcards</Link>
        </Button>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <p className="text-center text-sm text-muted-foreground">
        Cartão {index + 1} de {cards.length}
      </p>

      <div
        className={cn('flip-card mx-auto h-64 w-full max-w-xl cursor-pointer', flipped && 'is-flipped')}
        onClick={() => setFlipped((f) => !f)}
        role="button"
        tabIndex={0}
        onKeyDown={(e) => e.key === 'Enter' && setFlipped((f) => !f)}
      >
        <div className="flip-card-inner">
          <div className="flip-card-face flex items-center justify-center rounded-xl border bg-card p-6 text-center shadow-sm">
            <p className="text-lg font-medium leading-relaxed">{current.front}</p>
          </div>
          <div className="flip-card-back flex items-center justify-center overflow-y-auto rounded-xl border bg-card p-6 text-center shadow-sm">
            <p className="whitespace-pre-line text-sm leading-relaxed">{current.back}</p>
          </div>
        </div>
      </div>

      {!flipped ? (
        <p className="text-center text-sm text-muted-foreground">Clique no cartão para ver a resposta.</p>
      ) : (
        <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
          {RATINGS.map((r) => (
            <Button key={r.key} type="button" disabled={isPending} className={r.className} onClick={() => handleRate(r.key)}>
              {RATING_LABELS[r.key]}
            </Button>
          ))}
        </div>
      )}
    </div>
  )
}
