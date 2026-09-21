import { redirect } from 'next/navigation'
import { ShieldCheck } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { DeveloperRequestActions } from '@/components/admin/developer-request-actions'
import { Card, CardContent } from '@/components/ui/card'
import { EmptyState } from '@/components/shared/empty-state'
import { formatDate } from '@/lib/utils/format'

// Só admins acessam esta página — checado aqui (Server Component) para não
// nem renderizar a UI para quem não pode usá-la, além da proteção real que
// já vem do RLS (profiles_admin_select/update) em qualquer ação tomada aqui.
export default async function AdminRequestsPage() {
  const supabase = createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: profile } = await supabase.from('profiles').select('is_admin').eq('id', user.id).single()
  if (!profile?.is_admin) redirect('/dashboard')

  const { data: pending } = await supabase
    .from('profiles')
    .select('id, full_name, email, admin_requested_at')
    .not('admin_requested_at', 'is', null)
    .eq('is_admin', false)
    .order('admin_requested_at', { ascending: true })

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">Solicitações de desenvolvedor</h1>
        <p className="text-sm text-muted-foreground">Aprove ou rejeite pedidos de acesso administrativo.</p>
      </div>

      {!pending || pending.length === 0 ? (
        <EmptyState icon={ShieldCheck} title="Nenhuma solicitação pendente" description="Tudo em dia por aqui." />
      ) : (
        <div className="space-y-3">
          {pending.map((request) => (
            <Card key={request.id}>
              <CardContent className="flex flex-col gap-3 pt-6 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <p className="text-sm font-medium">{request.full_name ?? 'Sem nome'}</p>
                  <p className="text-sm text-muted-foreground">{request.email}</p>
                  <p className="text-xs text-muted-foreground">
                    Solicitado em {request.admin_requested_at ? formatDate(request.admin_requested_at) : '—'}
                  </p>
                </div>
                <DeveloperRequestActions userId={request.id} />
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  )
}
