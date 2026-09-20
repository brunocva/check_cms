'use client'

import { useState, useTransition } from 'react'
import { toast } from 'sonner'
import { createFlashcard } from '@/lib/actions/flashcards'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { Label } from '@/components/ui/label'
import { Select } from '@/components/ui/select'
import type { Subject } from '@/lib/types'

export function FlashcardForm({ subjects, onCreated }: { subjects: Subject[]; onCreated?: () => void }) {
  const [front, setFront] = useState('')
  const [back, setBack] = useState('')
  const [subjectId, setSubjectId] = useState('')
  const [isPending, startTransition] = useTransition()

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    startTransition(async () => {
      const result = await createFlashcard({ front, back, subjectId: subjectId || null })
      if (result.error) {
        toast.error(result.error)
      } else {
        toast.success('Flashcard criado.')
        setFront('')
        setBack('')
        onCreated?.()
      }
    })
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="front">Frente</Label>
        <Textarea id="front" value={front} onChange={(e) => setFront(e.target.value)} rows={2} required />
      </div>
      <div className="space-y-2">
        <Label htmlFor="back">Verso (resposta + explicação)</Label>
        <Textarea id="back" value={back} onChange={(e) => setBack(e.target.value)} rows={3} required />
      </div>
      <div className="space-y-2">
        <Label htmlFor="subject">Matéria</Label>
        <Select id="subject" value={subjectId} onChange={(e) => setSubjectId(e.target.value)}>
          <option value="">Sem matéria</option>
          {subjects.map((s) => (
            <option key={s.id} value={s.id}>
              {s.name}
            </option>
          ))}
        </Select>
      </div>
      <Button type="submit" disabled={isPending}>
        {isPending ? 'Salvando...' : 'Criar flashcard'}
      </Button>
    </form>
  )
}
