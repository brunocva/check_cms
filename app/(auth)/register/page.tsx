import type { Metadata } from 'next'
import { RegisterForm } from '@/components/auth/register-form'

export const metadata: Metadata = { title: 'Criar conta — Simulador de Provas' }

export default function RegisterPage() {
  return (
    <div className="space-y-6">
      <div className="space-y-1 text-center">
        <h1 className="text-xl font-semibold">Criar conta</h1>
        <p className="text-sm text-muted-foreground">Comece a montar seu banco de questões e simulados.</p>
      </div>
      <RegisterForm />
    </div>
  )
}
