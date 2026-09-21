'use client'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { Button } from '@/components/ui/button'

// Paginação da lista de questões (10 por página), via ?page= na URL —
// mesmo padrão de QuestionFilters, para funcionar em conjunto com os filtros.
export function QuestionPagination({ currentPage, totalPages }: { currentPage: number; totalPages: number }) {
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()

  function goToPage(page: number) {
    const params = new URLSearchParams(searchParams.toString())
    if (page <= 1) params.delete('page')
    else params.set('page', String(page))
    router.push(`${pathname}?${params.toString()}`)
  }

  if (totalPages <= 1) return null

  return (
    <div className="flex items-center justify-center gap-3">
      <Button type="button" variant="outline" size="icon" disabled={currentPage <= 1} onClick={() => goToPage(currentPage - 1)}>
        <ChevronLeft className="h-4 w-4" />
      </Button>
      <span className="text-sm text-muted-foreground">
        Página {currentPage} de {totalPages}
      </span>
      <Button type="button" variant="outline" size="icon" disabled={currentPage >= totalPages} onClick={() => goToPage(currentPage + 1)}>
        <ChevronRight className="h-4 w-4" />
      </Button>
    </div>
  )
}
