import { format, formatDistanceToNow } from 'date-fns'
import { ptBR } from 'date-fns/locale'

export function formatDate(iso: string | null | undefined, pattern = "dd/MM/yyyy") {
  if (!iso) return '—'
  return format(new Date(iso), pattern, { locale: ptBR })
}

export function formatDateTime(iso: string | null | undefined) {
  if (!iso) return '—'
  return format(new Date(iso), "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })
}

export function formatRelative(iso: string | null | undefined) {
  if (!iso) return '—'
  return formatDistanceToNow(new Date(iso), { addSuffix: true, locale: ptBR })
}

export function formatPercent(value: number, digits = 0) {
  return `${value.toFixed(digits)}%`
}

export const DIFFICULTY_LABELS: Record<string, string> = {
  facil: 'Fácil',
  media: 'Média',
  dificil: 'Difícil',
}

export const MODE_LABELS: Record<string, string> = {
  geral: 'Prova geral',
  materia: 'Por matéria',
  tag: 'Por tag',
  personalizada: 'Personalizada',
}

export const FLASHCARD_STATUS_LABELS: Record<string, string> = {
  novo: 'Novo',
  revisando: 'Revisando',
  dominado: 'Dominado',
}

export const RATING_LABELS: Record<string, string> = {
  errei: 'Errei',
  dificil: 'Difícil',
  bom: 'Bom',
  facil: 'Fácil',
}
