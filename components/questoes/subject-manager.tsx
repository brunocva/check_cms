'use client'

import { useState, useTransition } from 'react'
import { Trash2 } from 'lucide-react'
import { toast } from 'sonner'
import { createSubject, deleteSubject } from '@/lib/actions/subjects'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import type { Subject } from '@/lib/types'

// CRUD simples de matérias (criar/excluir). Sem edição de nome por
// simplicidade — basta excluir e recriar caso precise renomear.
export function SubjectManager({ subjects }: { subjects: Subject[] }) {
  const [name, setName] = useState('')
  const [isPending, startTransition] = useTransition()

  function handleCreate(e: React.FormEvent) {
    e.preventDefault()
    startTransition(async () => {
      const result = await createSubject({ name })
      if (result.error) {
        toast.error(result.error)
      } else {
        setName('')
        toast.success('Matéria criada.')
      }
    })
  }

  return (
    <div className="space-y-3">
      <form onSubmit={handleCreate} className="flex flex-wrap items-center gap-2">
        <Input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Nova matéria (ex.: Primeiros Socorros)"
          className="max-w-[260px]"
        />
        <Button type="submit" size="sm" disabled={isPending || !name.trim()}>
          Adicionar matéria
        </Button>
      </form>

      <div className="flex flex-wrap gap-2">
        {subjects.map((subject) => (
          <div key={subject.id} className="flex items-center gap-1.5 rounded-full border bg-secondary px-2.5 py-1 text-xs font-medium">
            {subject.name}
            <form action={deleteSubject}>
              <input type="hidden" name="id" value={subject.id} />
              <button type="submit" aria-label={`Excluir ${subject.name}`}>
                <Trash2 className="h-3 w-3 opacity-60 hover:opacity-100" />
              </button>
            </form>
          </div>
        ))}
        {subjects.length === 0 && <p className="text-sm text-muted-foreground">Nenhuma matéria ainda.</p>}
      </div>
    </div>
  )
}
