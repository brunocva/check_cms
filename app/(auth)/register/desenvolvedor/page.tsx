import type { Metadata } from 'next'
import { RegisterForm } from '@/components/auth/register-form'

export const metadata: Metadata = { title: 'Cadastro de desenvolvedor — Simulador de Provas' }

export default function RegisterDeveloperPage() {
  return (
    <div className="space-y-6">
      <div className="space-y-1 text-center">
        <h1 className="text-xl font-semibold">Cadastro de desenvolvedor</h1>
        <p className="text-sm text-muted-foreground">
          Sua conta é criada normalmente, mas o acesso administrativo só é liberado depois que um administrador
          aprovar sua solicitação.
        </p>
      </div>
      <RegisterForm devMode />
    </div>
  )
}
