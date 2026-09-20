'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { BarChart3, LayoutDashboard, ListChecks, Sparkles, SquareStack } from 'lucide-react'
import { cn } from '@/lib/utils'

const NAV_ITEMS = [
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/simulado', label: 'Simulado', icon: SquareStack },
  { href: '/progresso', label: 'Progresso', icon: BarChart3 },
  { href: '/questoes', label: 'Questões', icon: ListChecks },
  { href: '/flashcards', label: 'Flashcards', icon: Sparkles },
] as const

export function Sidebar() {
  const pathname = usePathname()

  return (
    <nav className="flex flex-row gap-1 overflow-x-auto p-2 md:flex-col md:overflow-visible md:p-3">
      {NAV_ITEMS.map((item) => {
        const isActive = pathname === item.href || pathname.startsWith(`${item.href}/`)
        const Icon = item.icon
        return (
          <Link
            key={item.href}
            href={item.href}
            className={cn(
              'flex shrink-0 items-center gap-3 whitespace-nowrap rounded-md px-3 py-2 text-sm font-medium transition-colors',
              isActive ? 'bg-primary text-primary-foreground' : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground'
            )}
          >
            <Icon className="h-4 w-4" />
            {item.label}
          </Link>
        )
      })}
    </nav>
  )
}
