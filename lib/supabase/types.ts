// Tipos do banco de dados, escritos à mão para casar exatamente com as
// migrations em /supabase/migrations. Usados para tipar o client Supabase
// (createClient<Database>()) em todo o app.
//
// Observação: versões recentes de @supabase/supabase-js exigem que cada
// tabela declare `Relationships` (mesmo vazio) e que o schema declare
// `Views`/`Functions`/`Enums`/`CompositeTypes` para casar com o tipo
// `GenericSchema` do postgrest-js — sem isso, a inferência de tipos das
// queries cai silenciosamente para `never`. Seguimos aqui o mesmo formato
// que o `supabase gen types typescript` geraria.

export type Difficulty = 'facil' | 'media' | 'dificil'
export type ExamMode = 'geral' | 'materia' | 'tag' | 'personalizada'
export type FlashcardStatus = 'novo' | 'revisando' | 'dominado'
export type FlashcardRating = 'errei' | 'dificil' | 'bom' | 'facil'

export interface QuestionOption {
  key: string
  text: string
}

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          full_name: string | null
          email: string | null
          is_admin: boolean
          admin_requested_at: string | null
          created_at: string
        }
        Insert: {
          id: string
          full_name?: string | null
          email?: string | null
          is_admin?: boolean
          admin_requested_at?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          full_name?: string | null
          email?: string | null
          is_admin?: boolean
          admin_requested_at?: string | null
          created_at?: string
        }
        Relationships: []
      }
      subjects: {
        Row: { id: string; user_id: string; name: string; created_at: string }
        Insert: { id?: string; user_id: string; name: string; created_at?: string }
        Update: { id?: string; user_id?: string; name?: string; created_at?: string }
        Relationships: []
      }
      tags: {
        Row: { id: string; user_id: string; name: string; color: string; created_at: string }
        Insert: { id?: string; user_id: string; name: string; color?: string; created_at?: string }
        Update: { id?: string; user_id?: string; name?: string; color?: string; created_at?: string }
        Relationships: []
      }
      questions: {
        Row: {
          id: string
          user_id: string
          subject_id: string | null
          statement: string
          options: QuestionOption[]
          correct_option: string
          explanation: string | null
          difficulty: Difficulty
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          subject_id?: string | null
          statement: string
          options: QuestionOption[]
          correct_option: string
          explanation?: string | null
          difficulty?: Difficulty
          created_at?: string
        }
        Update: Partial<Database['public']['Tables']['questions']['Insert']>
        Relationships: []
      }
      question_tags: {
        Row: { question_id: string; tag_id: string }
        Insert: { question_id: string; tag_id: string }
        Update: { question_id?: string; tag_id?: string }
        Relationships: []
      }
      exam_sessions: {
        Row: {
          id: string
          user_id: string
          mode: ExamMode
          subject_id: string | null
          tag_id: string | null
          question_ids: string[]
          total_questions: number
          correct_count: number
          score: number
          started_at: string
          finished_at: string | null
        }
        Insert: {
          id?: string
          user_id: string
          mode: ExamMode
          subject_id?: string | null
          tag_id?: string | null
          question_ids: string[]
          total_questions: number
          correct_count?: number
          score?: number
          started_at?: string
          finished_at?: string | null
        }
        Update: Partial<Database['public']['Tables']['exam_sessions']['Insert']>
        Relationships: []
      }
      answers: {
        Row: {
          id: string
          session_id: string
          user_id: string
          question_id: string
          selected_option: string
          is_correct: boolean
          created_at: string
        }
        Insert: {
          id?: string
          session_id: string
          user_id: string
          question_id: string
          selected_option: string
          is_correct: boolean
          created_at?: string
        }
        Update: Partial<Database['public']['Tables']['answers']['Insert']>
        Relationships: []
      }
      flashcards: {
        Row: {
          id: string
          user_id: string
          question_id: string | null
          subject_id: string | null
          front: string
          back: string
          status: FlashcardStatus
          repetitions: number
          interval_days: number
          next_review_date: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          question_id?: string | null
          subject_id?: string | null
          front: string
          back: string
          status?: FlashcardStatus
          repetitions?: number
          interval_days?: number
          next_review_date?: string
          created_at?: string
          updated_at?: string
        }
        Update: Partial<Database['public']['Tables']['flashcards']['Insert']>
        Relationships: []
      }
      flashcard_reviews: {
        Row: { id: string; flashcard_id: string; user_id: string; rating: FlashcardRating; reviewed_at: string }
        Insert: { id?: string; flashcard_id: string; user_id: string; rating: FlashcardRating; reviewed_at?: string }
        Update: Partial<Database['public']['Tables']['flashcard_reviews']['Insert']>
        Relationships: []
      }
    }
    Views: Record<string, never>
    Functions: Record<string, never>
    Enums: Record<string, never>
    CompositeTypes: Record<string, never>
  }
}
