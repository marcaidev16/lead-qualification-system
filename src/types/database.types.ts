// Database types for Supabase tables

export type UserRole = 'owner' | 'admin' | 'user' | 'viewer'

export interface Organization {
  id: string
  name: string
  slug: string
  plan: string
  settings: Record<string, any>
  created_at: string
  updated_at: string
}

export interface OrganizationUser {
  id: string
  organization_id: string
  user_id: string
  role: UserRole
  created_at: string
}

export interface Product {
  id: string
  organization_id: string
  name: string
  description: string | null
  keywords: string[]
  patterns: Record<string, any>
  exclusions: string[]
  compatibility: string[]
  scoring_base: number
  priority: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface NeedType {
  id: string
  organization_id: string
  name: string
  description: string | null
  priority: number
  keywords: string[]
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Lead {
  id: string
  organization_id: string

  // Original data
  full_name: string | null
  email: string | null
  company: string | null
  subject: string | null
  body: string | null

  // AI Classification
  tipo_necesidad: string | null
  subtipo_necesidad: string | null
  productos_servicios: string[]
  urgencia: string | null
  sentimiento: string | null
  scoring: number
  ai_reasoning: string | null
  palabras_clave_detectadas: string[]
  next_steps_suggested: string | null

  // Enrichment
  empresa_verificada: boolean
  empresa_nombre_oficial: string | null
  empresa_cif: string | null
  empresa_web: string | null
  empresa_descripcion: string | null
  empresa_sector: string | null
  empresa_empleados_rango: string | null
  empresa_facturacion_estimada: string | null
  empresa_ciudad: string | null
  empresa_provincia: string | null
  empresa_pais: string | null
  empresa_telefono: string | null
  empresa_linkedin: string | null
  lead_email_verificado: boolean
  lead_email_score: number
  empresa_stack_tecnologico: string[]
  empresa_madurez_digital: string | null

  // Metadata
  odoo_lead_id: number | null
  processed_at: string
  created_at: string
}

export interface WorkflowConfig {
  id: string
  organization_id: string
  workflow_name: string
  is_active: boolean
  config: Record<string, any>
  last_run: string | null
  created_at: string
}

// Helper types
export interface Database {
  public: {
    Tables: {
      organizations: {
        Row: Organization
        Insert: Omit<Organization, 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Omit<Organization, 'id' | 'created_at' | 'updated_at'>>
      }
      organization_users: {
        Row: OrganizationUser
        Insert: Omit<OrganizationUser, 'id' | 'created_at'>
        Update: Partial<Omit<OrganizationUser, 'id' | 'created_at'>>
      }
      products: {
        Row: Product
        Insert: Omit<Product, 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Omit<Product, 'id' | 'created_at' | 'updated_at'>>
      }
      need_types: {
        Row: NeedType
        Insert: Omit<NeedType, 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Omit<NeedType, 'id' | 'created_at' | 'updated_at'>>
      }
      leads: {
        Row: Lead
        Insert: Omit<Lead, 'id' | 'processed_at' | 'created_at'>
        Update: Partial<Omit<Lead, 'id' | 'processed_at' | 'created_at'>>
      }
      workflow_config: {
        Row: WorkflowConfig
        Insert: Omit<WorkflowConfig, 'id' | 'created_at'>
        Update: Partial<Omit<WorkflowConfig, 'id' | 'created_at'>>
      }
    }
  }
}
