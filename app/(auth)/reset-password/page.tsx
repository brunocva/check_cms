import type { Metadata } from 'next'
import { ResetPasswordForm } from '@/components/auth/reset-password-form'

export const metadata: Metadata = { title: 'Redefinir senha — Simulador de Provas' }

export default function ResetPasswordPage() {
  return (
    <div className="space-y-6">
      <div className="space-y-1 text-center">
        <h1 className="text-xl font-semibold">Defina sua nova senha</h1>
        <p className="text-sm text-muted-foreground">Você chegou aqui pelo link enviado por e-mail.</p>
      </div>
      <ResetPasswordForm />
    </div>
  )
}
