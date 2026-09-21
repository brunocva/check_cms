// Tipos de conveniência derivados do schema do banco (lib/supabase/types.ts),
// para não repetir `Database['public']['Tables']['x']['Row']` em todo lugar.

import type {
  Database,
  Difficulty,
  ExamMode,
  FlashcardRating,
  FlashcardStatus,
  QuestionOption,
} from './supabase/types'

export type Profile = Database['public']['Tables']['profiles']['Row']
export type Subject = Database['public']['Tables']['subjects']['Row']
export type Tag = Database['public']['Tables']['tags']['Row']
export type Question = Database['public']['Tables']['questions']['Row']
export type ExamSession = Database['public']['Tables']['exam_sessions']['Row']
export type Answer = Database['public']['Tables']['answers']['Row']
export type Flashcard = Database['public']['Tables']['flashcards']['Row']
export type FlashcardReview = Database['public']['Tables']['flashcard_reviews']['Row']

export type { Difficulty, ExamMode, FlashcardRating, FlashcardStatus, QuestionOption }

// Questão com suas tags já resolvidas (usada nas listagens e no simulador).
export type QuestionWithTags = Question & { tags: Tag[] }
