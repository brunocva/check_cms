'use client'

import { useState, useTransition } from 'react'
import { Check, Pencil, Trash2, X } from 'lucide-react'
import { toast } from 'sonner'
import { createTag, deleteTag, updateTag } from '@/lib/actions/tags'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import type { Tag } from '@/lib/types'

// CRUD completo de tags (nome + cor). Fica embutido na página de Questões
// porque o spec não previu uma rota própria para gerenciamento de tags.
export function TagManager({ tags }: { tags: Tag[] }) {
  const [name, setName] = useState('')
  const [color, setColor] = useState('#6366f1')
  const [isPending, startTransition] = useTransition()

  const [editingId, setEditingId] = useState<string | null>(null)
  const [editName, setEditName] = useState('')
  const [editColor, setEditColor] = useState('#6366f1')

  function handleCreate(e: React.FormEvent) {
    e.preventDefault()
    startTransition(async () => {
      const result = await createTag({ name, color })
      if (result.error) {
        toast.error(result.error)
      } else {
        setName('')
        toast.success('Tag criada.')
      }
    })
  }

  function startEdit(tag: Tag) {
    setEditingId(tag.id)
    setEditName(tag.name)
    setEditColor(tag.color)
  }

  function saveEdit() {
    if (!editingId) return
    startTransition(async () => {
      const result = await updateTag({ id: editingId, name: editName, color: editColor })
      if (result.error) toast.error(result.error)
      setEditingId(null)
    })
  }

  return (
    <div className="space-y-3">
      <form onSubmit={handleCreate} className="flex flex-wrap items-center gap-2">
        <input
          type="color"
          value={color}
          onChange={(e) => setColor(e.target.value)}
          className="h-9 w-9 cursor-pointer rounded border"
          aria-label="Cor da nova tag"
        />
        <Input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Nova tag (ex.: cálculo)"
          className="max-w-[220px]"
        />
        <Button type="submit" size="sm" disabled={isPending || !name.trim()}>
          Adicionar tag
        </Button>
      </form>

      <div className="flex flex-wrap gap-2">
        {tags.map((tag) =>
          editingId === tag.id ? (
            <div key={tag.id} className="flex items-center gap-1 rounded-full border px-2 py-1">
              <input
                type="color"
                value={editColor}
                onChange={(e) => setEditColor(e.target.value)}
                className="h-5 w-5 cursor-pointer rounded"
                aria-label="Cor"
              />
              <Input value={editName} onChange={(e) => setEditName(e.target.value)} className="h-6 w-28 px-1 text-xs" />
              <button type="button" onClick={saveEdit} aria-label="Salvar">
                <Check className="h-3.5 w-3.5 text-success" />
              </button>
              <button type="button" onClick={() => setEditingId(null)} aria-label="Cancelar">
                <X className="h-3.5 w-3.5 text-muted-foreground" />
              </button>
            </div>
          ) : (
            <div
              key={tag.id}
              className="group flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-medium"
              style={{ backgroundColor: `${tag.color}1a`, borderColor: `${tag.color}66`, color: tag.color }}
            >
              {tag.name}
              <button type="button" onClick={() => startEdit(tag)} aria-label={`Editar ${tag.name}`}>
                <Pencil className="h-3 w-3 opacity-60 hover:opacity-100" />
              </button>
              <form action={deleteTag}>
                <input type="hidden" name="id" value={tag.id} />
                <button type="submit" aria-label={`Excluir ${tag.name}`}>
                  <Trash2 className="h-3 w-3 opacity-60 hover:opacity-100" />
                </button>
              </form>
            </div>
          )
        )}
        {tags.length === 0 && <p className="text-sm text-muted-foreground">Nenhuma tag ainda.</p>}
      </div>
    </div>
  )
}
