import { Plane } from 'lucide-react'

export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-8 bg-muted/30 px-4 py-12">
      <div className="flex items-center gap-2 text-lg font-semibold">
        <Plane className="h-6 w-6 text-primary" />
        Simulador de Provas
      </div>
      <div className="w-full max-w-sm rounded-xl border bg-card p-6 shadow-sm">{children}</div>
    </div>
  )
}
