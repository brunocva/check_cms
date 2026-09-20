'use client'

import { useState, useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'
import { Plus, Trash2 } from 'lucide-react'
import { createQuestion, updateQuestion } from '@/lib/actions/questions'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Label } from '@/components/ui/label'
import { Select } from '@/components/ui/select'
import { Checkbox } from '@/components/ui/checkbox'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import type { Difficulty, Question, QuestionOption, Subject, Tag } from '@/lib/types'

const KEYS = ['A', 'B', 'C', 'D', 'E', 'F']

interface QuestionFormProps {
  subjects: Subject[]
  tags: Tag[]
  initialQuestion?: Question & { tagIds: string[] }
}

export function QuestionForm({ subjects, tags, initialQuestion }: QuestionFormProps) {
  const router = useRouter()
  const [isPending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)

  const [statement, setStatement] = useState(initialQuestion?.statement ?? '')
  const [subjectId, setSubjectId] = useState(initialQuestion?.subject_id ?? '')
  const [difficulty, setDifficulty] = useState<Difficulty>(initialQuestion?.difficulty ?? 'media')
  const [explanation, setExplanation] = useState(initialQuestion?.explanation ?? '')
  const [options, setOptions] = useState<QuestionOption[]>(
    initialQuestion?.options ?? [
      { key: 'A', text: '' },
      { key: 'B', text: '' },
      { key: 'C', text: '' },
      { key: 'D', text: '' },
    ]
  )
  const [correctOption, setCorrectOption] = useState(initialQuestion?.correct_option ?? 'A')
  const [tagIds, setTagIds] = useState<string[]>(initialQuestion?.tagIds ?? [])

  function updateOptionText(index: number, text: string) {
    setOptions((prev) => prev.map((o, i) => (i === index ? { ...o, text } : o)))
  }

  function addOption() {
    setOptions((prev) => (prev.length >= KEYS.length ? prev : [...prev, { key: KEYS[prev.length], text: '' }]))
  }

  function removeOption(index: number) {
    if (options.length <= 2) return
    const removedKey = options[index].key
    setOptions((prev) => prev.filter((_, i) => i !== index).map((o, i) => ({ ...o, key: KEYS[i] })))
    setCorrectOption((prev) => (prev === removedKey ? 'A' : prev))
  }

  function toggleTag(id: string) {
    setTagIds((prev) => (prev.includes(id) ? prev.filter((t) => t !== id) : [...prev, id]))
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError(null)

    const payload = {
      statement,
      subjectId: subjectId || null,
      difficulty,
      options,
      correctOption,
      explanation,
      tagIds,
    }

    startTransition(async () => {
      const result = initialQuestion
        ? await updateQuestion({ id: initialQuestion.id, ...payload })
        : await createQuestion(payload)

      // Em caso de sucesso, a action já faz redirect('/questoes') e este
      // código sequer chega a rodar.
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
        <Label htmlFor="statement">Enunciado</Label>
        <Textarea id="statement" value={statement} onChange={(e) => setStatement(e.target.value)} rows={4} required />
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <div className="space-y-2">
          <Label htmlFor="subject">Matéria</Label>
          <Select id="subject" value={subjectId ?? ''} onChange={(e) => setSubjectId(e.target.value)}>
            <option value="">Sem matéria</option>
            {subjects.map((s) => (
              <option key={s.id} value={s.id}>
                {s.name}
              </option>
            ))}
          </Select>
        </div>
        <div className="space-y-2">
          <Label htmlFor="difficulty">Dificuldade</Label>
          <Select id="difficulty" value={difficulty} onChange={(e) => setDifficulty(e.target.value as Difficulty)}>
            <option value="facil">Fácil</option>
            <option value="media">Média</option>
            <option value="dificil">Difícil</option>
          </Select>
        </div>
      </div>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="text-base">Alternativas</CardTitle>
          <Button type="button" variant="outline" size="sm" onClick={addOption} disabled={options.length >= KEYS.length}>
            <Plus className="h-4 w-4" /> Adicionar
          </Button>
        </CardHeader>
        <CardContent className="space-y-3">
          {options.map((option, index) => (
            <div key={option.key} className="flex items-center gap-2">
              <input
                type="radio"
                name="correctOption"
                aria-label={`Marcar ${option.key} como correta`}
                checked={correctOption === option.key}
                onChange={() => setCorrectOption(option.key)}
                className="h-4 w-4 shrink-0"
              />
              <span className="w-5 shrink-0 text-sm font-semibold">{option.key})</span>
              <Input
                value={option.text}
                onChange={(e) => updateOptionText(index, e.target.value)}
                placeholder={`Texto da alternativa ${option.key}`}
              />
              <Button
                type="button"
                variant="ghost"
                size="icon"
                onClick={() => removeOption(index)}
                disabled={options.length <= 2}
                aria-label={`Remover alternativa ${option.key}`}
              >
                <Trash2 className="h-4 w-4" />
              </Button>
            </div>
          ))}
          <p className="text-xs text-muted-foreground">Selecione o botão à esquerda da alternativa correta.</p>
        </CardContent>
      </Card>

      <div className="space-y-2">
        <Label htmlFor="explanation">Explicação (aparece no gabarito comentado)</Label>
        <Textarea id="explanation" value={explanation} onChange={(e) => setExplanation(e.target.value)} rows={3} />
      </div>

      <div className="space-y-2">
        <Label>Tags</Label>
        <div className="flex flex-wrap gap-2">
          {tags.map((tag) => {
            const active = tagIds.includes(tag.id)
            return (
              <button
                type="button"
                key={tag.id}
                onClick={() => toggleTag(tag.id)}
                className="flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-medium transition-opacity"
                style={{
                  backgroundColor: active ? `${tag.color}33` : 'transparent',
                  borderColor: `${tag.color}66`,
                  color: tag.color,
                  opacity: active ? 1 : 0.55,
                }}
              >
                <Checkbox checked={active} readOnly className="pointer-events-none" tabIndex={-1} />
                {tag.name}
              </button>
            )
          })}
          {tags.length === 0 && <p className="text-sm text-muted-foreground">Nenhuma tag cadastrada ainda.</p>}
        </div>
      </div>

      <div className="flex gap-2">
        <Button type="submit" disabled={isPending}>
          {isPending ? 'Salvando...' : initialQuestion ? 'Salvar alterações' : 'Criar questão'}
        </Button>
        <Button type="button" variant="outline" onClick={() => router.push('/questoes')}>
          Cancelar
        </Button>
      </div>
    </form>
  )
}
