import { createClient } from '@/lib/supabase/server'
import { ConfigForm } from '@/components/simulado/config-form'
import { Card, CardContent } from '@/components/ui/card'

export default async function SimuladoPage() {
  const supabase = createClient()

  const [{ data: subjects }, { data: tags }] = await Promise.all([
    supabase.from('subjects').select('*').order('name'),
    supabase.from('tags').select('*').order('name'),
  ])

  return (
    <div className="mx-auto max-w-xl space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">Novo simulado</h1>
        <p className="text-sm text-muted-foreground">Configure o modo e a quantidade de questões.</p>
      </div>
      <Card>
        <CardContent className="pt-6">
          <ConfigForm subjects={subjects ?? []} tags={tags ?? []} />
        </CardContent>
      </Card>
    </div>
  )
}
