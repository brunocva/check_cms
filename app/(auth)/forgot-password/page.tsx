import type { Metadata } from 'next'
import { ForgotPasswordForm } from '@/components/auth/forgot-password-form'

export const metadata: Metadata = { title: 'Recuperar senha — Simulador de Provas' }

export default function ForgotPasswordPage() {
  return (
    <div className="space-y-6">
      <div className="space-y-1 text-center">
        <h1 className="text-xl font-semibold">Recuperar senha</h1>
        <p className="text-sm text-muted-foreground">Informe seu e-mail para receber um link de redefinição.</p>
      </div>
      <ForgotPasswordForm />
    </div>
  )
}
