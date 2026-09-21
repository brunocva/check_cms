'use client'

import { useState, useTransition } from 'react'
import Link from 'next/link'
import { signUpAction } from '@/lib/actions/auth'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

export function RegisterForm({ devMode = false }: { devMode?: boolean }) {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [needsConfirmation, setNeedsConfirmation] = useState(false)
  const [isPending, startTransition] = useTransition()

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError(null)

    if (password !== confirmPassword) {
      setError('As senhas não conferem.')
      return
    }
    if (password.length < 6) {
      setError('A senha deve ter pelo menos 6 caracteres.')
      return
    }

    startTransition(async () => {
      const result = await signUpAction({ name, email, password, devRequest: devMode })
      if (result?.error) setError(result.error)
      if (result?.needsEmailConfirmation) setNeedsConfirmation(true)
    })
  }

  if (needsConfirmation) {
    return (
      <div className="space-y-3 rounded-md bg-success/10 p-4 text-sm text-success">
        <p className="font-medium">Quase lá!</p>
        <p>
          Enviamos um link de confirmação para <strong>{email}</strong>. Abra seu e-mail para ativar a conta.
        </p>
        {devMode && (
          <p>
            Depois de confirmar o e-mail, sua conta ainda fica pendente até um administrador aprovar o acesso de
            desenvolvedor.
          </p>
        )}
      </div>
    )
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {devMode && (
        <p className="rounded-md bg-accent p-3 text-sm text-accent-foreground">
          Este cadastro solicita acesso de desenvolvedor. Um administrador precisa aprovar antes que você tenha
          permissões administrativas.
        </p>
      )}
      {error && <p className="rounded-md bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}

      <div className="space-y-2">
        <Label htmlFor="name">Nome</Label>
        <Input id="name" value={name} onChange={(e) => setName(e.target.value)} required autoComplete="name" />
      </div>
      <div className="space-y-2">
        <Label htmlFor="email">E-mail</Label>
        <Input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
      </div>
      <div className="space-y-2">
        <Label htmlFor="password">Senha</Label>
        <Input
          id="password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          minLength={6}
          autoComplete="new-password"
        />
      </div>
      <div className="space-y-2">
        <Label htmlFor="confirmPassword">Confirmar senha</Label>
        <Input
          id="confirmPassword"
          type="password"
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
          required
          minLength={6}
          autoComplete="new-password"
        />
      </div>
      <Button type="submit" className="w-full" disabled={isPending}>
        {isPending ? 'Criando conta...' : devMode ? 'Solicitar acesso de desenvolvedor' : 'Criar conta'}
      </Button>

      <p className="text-center text-sm text-muted-foreground">
        Já tem conta?{' '}
        <Link href="/login" className="font-medium text-primary hover:underline">
          Entrar
        </Link>
      </p>

      {!devMode && (
        <p className="text-center text-sm text-muted-foreground">
          É desenvolvedor?{' '}
          <Link href="/register/desenvolvedor" className="font-medium text-primary hover:underline">
            Solicitar acesso administrativo
          </Link>
        </p>
      )}
    </form>
  )
}
