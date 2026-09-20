'use client'

import { useState } from 'react'
import { Plus, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { FlashcardForm } from './flashcard-form'
import type { Subject } from '@/lib/types'

export function NewFlashcardToggle({ subjects }: { subjects: Subject[] }) {
  const [open, setOpen] = useState(false)

  return (
    <div>
      <Button type="button" variant="outline" onClick={() => setOpen((o) => !o)}>
        {open ? <X className="h-4 w-4" /> : <Plus className="h-4 w-4" />}
        {open ? 'Cancelar' : 'Novo flashcard'}
      </Button>
      {open && (
        <Card className="mt-3">
          <CardContent className="pt-6">
            <FlashcardForm subjects={subjects} onCreated={() => setOpen(false)} />
          </CardContent>
        </Card>
      )}
    </div>
  )
}
