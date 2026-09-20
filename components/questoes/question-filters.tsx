'use client'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'
import { Select } from '@/components/ui/select'
import { DIFFICULTY_LABELS } from '@/lib/utils/format'
import type { Subject, Tag } from '@/lib/types'

// Atualiza a URL (?subject=&tag=&difficulty=) para que a página (Server
// Component) refaça a query já filtrada.
export function QuestionFilters({ subjects, tags }: { subjects: Subject[]; tags: Tag[] }) {
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()

  function updateParam(key: string, value: string) {
    const params = new URLSearchParams(searchParams.toString())
    if (value) params.set(key, value)
    else params.delete(key)
    router.push(`${pathname}?${params.toString()}`)
  }

  return (
    <div className="flex flex-wrap gap-2">
      <Select className="max-w-[200px]" value={searchParams.get('subject') ?? ''} onChange={(e) => updateParam('subject', e.target.value)}>
        <option value="">Todas as matérias</option>
        {subjects.map((s) => (
          <option key={s.id} value={s.id}>
            {s.name}
          </option>
        ))}
      </Select>

      <Select className="max-w-[200px]" value={searchParams.get('tag') ?? ''} onChange={(e) => updateParam('tag', e.target.value)}>
        <option value="">Todas as tags</option>
        {tags.map((t) => (
          <option key={t.id} value={t.id}>
            {t.name}
          </option>
        ))}
      </Select>

      <Select
        className="max-w-[180px]"
        value={searchParams.get('difficulty') ?? ''}
        onChange={(e) => updateParam('difficulty', e.target.value)}
      >
        <option value="">Qualquer dificuldade</option>
        {Object.entries(DIFFICULTY_LABELS).map(([key, label]) => (
          <option key={key} value={key}>
            {label}
          </option>
        ))}
      </Select>
    </div>
  )
}
