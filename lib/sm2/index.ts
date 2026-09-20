import type { FlashcardRating, FlashcardStatus } from '@/lib/types'

/**
 * Repetição espaçada — versão simplificada do SM-2.
 *
 * O SM-2 "de verdade" calcula um "ease factor" contínuo por cartão e um
 * intervalo que cresce multiplicativamente (interval * ease_factor). Para um
 * projeto pessoal isso é complexidade desnecessária, então usamos intervalos
 * fixos por autoavaliação (conforme pedido no spec do produto):
 *
 *   Errei   -> revisar HOJE de novo (intervalo 0, reinicia repetições)
 *   Difícil -> revisar em 1 dia
 *   Bom     -> revisar em 3 dias
 *   Fácil   -> revisar em 7 dias
 *
 * O `status` do cartão é derivado do histórico recente:
 *   - qualquer "Errei" joga o cartão de volta para "revisando"
 *   - repetições consecutivas de "Bom"/"Fácil" promovem o cartão a "dominado"
 *   - um cartão nunca revisado começa como "novo"
 */

export interface SM2State {
  status: FlashcardStatus
  repetitions: number
  interval_days: number
}

export interface SM2Result {
  status: FlashcardStatus
  repetitions: number
  interval_days: number
  next_review_date: string // formato YYYY-MM-DD
}

const INTERVAL_BY_RATING: Record<FlashcardRating, number> = {
  errei: 0,
  dificil: 1,
  bom: 3,
  facil: 7,
}

// Nº de repetições "boas" (bom/fácil) seguidas necessárias para considerar
// o cartão dominado. Definido baixo de propósito (uso pessoal, poucos
// cartões) — pode ser ajustado aqui sem tocar no resto do app.
const REPETITIONS_TO_MASTER = 3

export function computeNextReview(current: SM2State, rating: FlashcardRating): SM2Result {
  const interval_days = INTERVAL_BY_RATING[rating]

  let repetitions: number
  let status: FlashcardStatus

  if (rating === 'errei') {
    repetitions = 0
    status = 'revisando'
  } else {
    repetitions = current.repetitions + 1
    status = repetitions >= REPETITIONS_TO_MASTER ? 'dominado' : 'revisando'
  }

  const nextDate = addDays(new Date(), interval_days)

  return {
    status,
    repetitions,
    interval_days,
    next_review_date: toDateOnly(nextDate),
  }
}

function addDays(date: Date, days: number) {
  const result = new Date(date)
  result.setDate(result.getDate() + days)
  return result
}

function toDateOnly(date: Date) {
  return date.toISOString().slice(0, 10)
}

/** Um cartão está "para hoje" quando next_review_date <= hoje. */
export function isDueToday(nextReviewDate: string) {
  return nextReviewDate <= toDateOnly(new Date())
}
