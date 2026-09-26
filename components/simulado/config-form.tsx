'use client'

import { useState, useTransition } from 'react'
import { toast } from 'sonner'
import { createExamSession } from '@/lib/actions/exam'
import { Button } from '@/components/ui/button'
import { Select } from '@/components/ui/select'
import { Label } from '@/components/ui/label'
import { cn } from '@/lib/utils'
import { DIFFICULTY_LABELS, MODE_LABELS } from '@/lib/utils/format'
import type { Difficulty, ExamMode, Subject, Tag } from '@/lib/types'

const MODES: ExamMode[] = ['geral', 'materia', 'tag', 'personalizada']
const AMOUNTS = [5, 10, 20, 30]

export function ConfigForm({ subjects, tags }: { subjects: Subject[]; tags: Tag[] }) {
  const [mode, setMode] = useState<ExamMode>('geral')
  const [subjectId, setSubjectId] = useState('')
  const [tagId, setTagId] = useState('')
  const [difficulty, setDifficulty] = useState<Difficulty | ''>('')
  const [amount, setAmount] = useState(10)
  const [error, setError] = useState<string | null>(null)
  const [isPending, startTransition] = useTransition()

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError(null)

    startTransition(async () => {
      const result = await createExamSession({
        mode,
        subjectId: subjectId || null,
        tagId: tagId || null,
        difficulty: difficulty || null,
        amount,
      })
      // Sucesso redireciona dentro da action; só chegamos aqui em erro.
      if (result?.error) {
        setError(result.error)
        toast.error(result.error)
      }
    })
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {error && <p className="rounded-md bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}

      <div className="space-y-2">
        <Label>Modo</Label>
        <div className="grid gap-2 sm:grid-cols-2">
          {MODES.map((m) => (
            <button
              type="button"
              key={m}
              onClick={() => setMode(m)}
              className={cn(
                'rounded-lg border p-3 text-left text-sm font-medium transition-colors',
                mode === m ? 'border-primary bg-primary text-primary-foreground' : 'hover:bg-accent'
              )}
            >
              <span>{MODE_LABELS[m]}</span>
            </button>
          ))}
        </div>
      </div>

      {(mode === 'materia' || mode === 'personalizada') && (
        <div className="space-y-2">
          <Label htmlFor="subject">Matéria</Label>
          <Select id="subject" value={subjectId} onChange={(e) => setSubjectId(e.target.value)} required={mode === 'materia'}>
            <option value="">{mode === 'personalizada' ? 'Qualquer matéria' : 'Selecione...'}</option>
            {subjects.map((s) => (
              <option key={s.id} value={s.id}>
                {s.name}
              </option>
            ))}
          </Select>
        </div>
      )}

      {(mode === 'tag' || mode === 'personalizada') && (
        <div className="space-y-2">
          <Label htmlFor="tag">Tag</Label>
          <Select id="tag" value={tagId} onChange={(e) => setTagId(e.target.value)} required={mode === 'tag'}>
            <option value="">{mode === 'personalizada' ? 'Qualquer tag' : 'Selecione...'}</option>
            {tags.map((t) => (
              <option key={t.id} value={t.id}>
                {t.name}
              </option>
            ))}
          </Select>
        </div>
      )}

      {mode === 'personalizada' && (
        <div className="space-y-2">
          <Label htmlFor="difficulty">Dificuldade</Label>
          <Select id="difficulty" value={difficulty} onChange={(e) => setDifficulty(e.target.value as Difficulty)}>
            <option value="">Qualquer dificuldade</option>
            {Object.entries(DIFFICULTY_LABELS).map(([key, label]) => (
              <option key={key} value={key}>
                {label}
              </option>
            ))}
          </Select>
        </div>
      )}

      <div className="space-y-2">
        <Label>Número de questões</Label>
        <div className="flex gap-2">
          {AMOUNTS.map((n) => (
            <button
              type="button"
              key={n}
              onClick={() => setAmount(n)}
              className={cn(
                'flex h-10 w-14 items-center justify-center rounded-md border text-sm font-medium',
                amount === n ? 'border-primary bg-primary text-primary-foreground' : 'hover:bg-accent'
              )}
            >
              {n}
            </button>
          ))}
        </div>
        <p className="text-xs text-muted-foreground">
          Se houver menos questões disponíveis do que o solicitado, o simulado usa todas as elegíveis.
        </p>
      </div>

      <Button type="submit" size="lg" disabled={isPending}>
        {isPending ? 'Gerando simulado...' : 'Começar simulado'}
      </Button>
    </form>
  )
}
