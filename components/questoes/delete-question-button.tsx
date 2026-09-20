'use client'

import { Trash2 } from 'lucide-react'
import { deleteQuestion } from '@/lib/actions/questions'
import { Button } from '@/components/ui/button'

export function DeleteQuestionButton({ id }: { id: string }) {
  return (
    <form
      action={deleteQuestion}
      onSubmit={(e) => {
        if (!confirm('Excluir esta questão? Essa ação não pode ser desfeita.')) {
          e.preventDefault()
        }
      }}
    >
      <input type="hidden" name="id" value={id} />
      <Button type="submit" variant="ghost" size="icon" aria-label="Excluir questão">
        <Trash2 className="h-4 w-4" />
      </Button>
    </form>
  )
}
