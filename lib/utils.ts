import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

// Helper padrão do shadcn/ui: combina classes condicionais (clsx) e resolve
// conflitos de utilitários Tailwind (tailwind-merge).
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
