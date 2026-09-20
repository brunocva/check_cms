'use client'

import { useState, useTransition } from 'react'
import Link from 'next/link'
import { forgotPasswordAction } from '@/lib/actions/auth'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

export function ForgotPasswordForm() {
  const [email, setEmail] = useState('')
  const [sent, setSent] = useState(false)
  const [isPending, startTransition] = useTransition()

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    startTransition(async () => {
      await forgotPasswordAction({ email })
      setSent(true)
    })
  }

  if (sent) {
    return (
      <div className="space-y-3 rounded-md bg-success/10 p-4 text-sm text-success">
        <p>Se existir uma conta com esse e-mail, você receberá um link para redefinir sua senha.</p>
        <Link href="/login" className="font-medium underline">
          Voltar para o login
        </Link>
      </div>
    )
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="email">E-mail</Label>
        <Input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
      </div>
      <Button type="submit" className="w-full" disabled={isPending}>
        {isPending ? 'Enviando...' : 'Enviar link de recuperação'}
      </Button>
      <p className="text-center text-sm text-muted-foreground">
        <Link href="/login" className="font-medium text-primary hover:underline">
          Voltar para o login
        </Link>
      </p>
    </form>
  )
}
