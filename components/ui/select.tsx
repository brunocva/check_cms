import * as React from 'react'
import { ChevronDown } from 'lucide-react'
import { cn } from '@/lib/utils'

// Select nativo estilizado (em vez do Radix Select) para manter o projeto
// simples: menos JS, funciona de graça com formulários e leitores de tela.
export type SelectProps = React.SelectHTMLAttributes<HTMLSelectElement>

const Select = React.forwardRef<HTMLSelectElement, SelectProps>(({ className, children, ...props }, ref) => {
  // A classe passada (ex.: max-w-[200px]) vai no wrapper, não no <select>,
  // para se comportar corretamente como item de flex/grid.
  return (
    <div className={cn('relative w-full', className)}>
      <select
        ref={ref}
        className="flex h-9 w-full appearance-none rounded-md border border-input bg-background px-3 py-1 pr-8 text-sm shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50"
        {...props}
      >
        {children}
      </select>
      <ChevronDown className="pointer-events-none absolute right-2 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
    </div>
  )
})
Select.displayName = 'Select'

export { Select }
