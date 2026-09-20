'use client'

import { useFormStatus } from 'react-dom'
import { Button, type ButtonProps } from '@/components/ui/button'

// Botão de submit para forms de Server Action (`<form action={...}>`).
// Usa useFormStatus para saber quando a action está em andamento, sem
// precisar transformar o formulário inteiro em Client Component.
export function SubmitButton({
  children,
  pendingText = 'Enviando...',
  ...props
}: ButtonProps & { pendingText?: string }) {
  const { pending } = useFormStatus()

  return (
    <Button type="submit" disabled={pending} {...props}>
      {pending ? pendingText : children}
    </Button>
  )
}
