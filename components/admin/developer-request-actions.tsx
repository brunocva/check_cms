'use client'

import { useTransition } from 'react'
import { toast } from 'sonner'
import { Check, X } from 'lucide-react'
import { approveDeveloperRequest, rejectDeveloperRequest } from '@/lib/actions/admin'
import { Button } from '@/components/ui/button'

export function DeveloperRequestActions({ userId }: { userId: string }) {
  const [isPending, startTransition] = useTransition()

  function handleApprove() {
    startTransition(async () => {
      const result = await approveDeveloperRequest(userId)
      if (result?.error) toast.error(result.error)
      else toast.success('Acesso de desenvolvedor aprovado.')
    })
  }

  function handleReject() {
    if (!confirm('Rejeitar esta solicitação? A pessoa continua com uma conta comum.')) return
    startTransition(async () => {
      const result = await rejectDeveloperRequest(userId)
      if (result?.error) toast.error(result.error)
      else toast.success('Solicitação rejeitada.')
    })
  }

  return (
    <div className="flex shrink-0 items-center gap-2">
      <Button type="button" variant="outline" size="sm" disabled={isPending} onClick={handleReject}>
        <X className="h-4 w-4" /> Rejeitar
      </Button>
      <Button type="button" size="sm" disabled={isPending} onClick={handleApprove}>
        <Check className="h-4 w-4" /> Aprovar
      </Button>
    </div>
  )
}
