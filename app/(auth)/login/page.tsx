import { Suspense } from 'react'
import type { Metadata } from 'next'
import { LoginForm } from '@/components/auth/login-form'

export const metadata: Metadata = { title: 'Entrar — Simulador de Provas' }

export default function LoginPage() {
  return (
    <div className="space-y-6">
      <div className="space-y-1 text-center">
        <h1 className="text-xl font-semibold">Bem-vindo de volta</h1>
        <p className="text-sm text-muted-foreground">Entre para continuar seus estudos.</p>
      </div>
      {/* useSearchParams (para exibir o aviso de senha redefinida) exige Suspense. */}
      <Suspense fallback={null}>
        <LoginForm />
      </Suspense>
    </div>
  )
}
