import { GraduationCap } from 'lucide-react'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { Sidebar } from '@/components/layout/sidebar'
import { Topbar } from '@/components/layout/topbar'

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const supabase = createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  // Segunda camada de proteção além do middleware (defesa em profundidade).
  if (!user) redirect('/login')

  return (
    <div className="flex min-h-screen flex-col md:flex-row">
      <aside className="border-b md:w-64 md:shrink-0 md:border-b-0 md:border-r">
        <div className="flex items-center gap-2 p-4 text-base font-semibold">
          <GraduationCap className="h-5 w-5 text-primary" />
          Simulador de Provas
        </div>
        <Sidebar />
      </aside>

      <div className="flex flex-1 flex-col">
        <Topbar userEmail={user.email ?? null} />
        <main className="flex-1 p-4 md:p-6">{children}</main>
      </div>
    </div>
  )
}
