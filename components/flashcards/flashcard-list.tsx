import { Trash2 } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { TagBadge } from '@/components/tags/tag-badge'
import { deleteFlashcard } from '@/lib/actions/flashcards'
import { FLASHCARD_STATUS_LABELS, formatDate } from '@/lib/utils/format'
import type { Tag } from '@/lib/types'

export interface FlashcardListItem {
  id: string
  front: string
  status: string
  subjectName: string | null
  tags: Tag[]
  nextReviewDate: string
}

const STATUS_VARIANT: Record<string, 'secondary' | 'default' | 'success'> = {
  novo: 'secondary',
  revisando: 'default',
  dominado: 'success',
}

export function FlashcardList({ items }: { items: FlashcardListItem[] }) {
  return (
    <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {items.map((card) => (
        <Card key={card.id}>
          <CardContent className="space-y-2 pt-6">
            <div className="flex items-start justify-between gap-2">
              <Badge variant={STATUS_VARIANT[card.status] ?? 'secondary'}>{FLASHCARD_STATUS_LABELS[card.status]}</Badge>
              <form action={deleteFlashcard}>
                <input type="hidden" name="id" value={card.id} />
                <button type="submit" aria-label="Excluir flashcard" className="text-muted-foreground hover:text-destructive">
                  <Trash2 className="h-4 w-4" />
                </button>
              </form>
            </div>
            <p className="line-clamp-3 text-sm font-medium">{card.front}</p>
            <div className="flex flex-wrap items-center gap-1.5">
              {card.subjectName && <Badge variant="outline">{card.subjectName}</Badge>}
              {card.tags.map((tag) => (
                <TagBadge key={tag.id} tag={tag} />
              ))}
            </div>
            <p className="text-xs text-muted-foreground">Próxima revisão: {formatDate(card.nextReviewDate)}</p>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
