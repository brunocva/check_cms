import { LogOut } from 'lucide-react'
import { ThemeToggle } from './theme-toggle'
import { signOutAction } from '@/lib/actions/auth'
import { Button } from '@/components/ui/button'

export function Topbar({ userEmail }: { userEmail: string | null }) {
  return (
    <header className="flex items-center justify-between border-b px-4 py-3 md:px-6">
      <div className="truncate text-sm text-muted-foreground">{userEmail}</div>
      <div className="flex items-center gap-1">
        <ThemeToggle />
        <form action={signOutAction}>
          <Button type="submit" variant="ghost" size="icon" aria-label="Sair da conta">
            <LogOut className="h-4 w-4" />
          </Button>
        </form>
      </div>
    </header>
  )
}
