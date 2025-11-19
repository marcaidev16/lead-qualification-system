import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '@/lib/supabase'
import { toast } from '@/components/ui/use-toast'

interface SignupData {
  email: string
  password: string
  organizationName: string
  fullName: string
}

interface LoginData {
  email: string
  password: string
}

export function useAuth() {
  const [isLoading, setIsLoading] = useState(false)
  const navigate = useNavigate()

  const signup = async (data: SignupData) => {
    setIsLoading(true)
    try {
      // 1. Create auth user
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: data.email,
        password: data.password,
        options: {
          data: {
            full_name: data.fullName,
          },
        },
      })

      if (authError) throw authError
      if (!authData.user) throw new Error('Failed to create user')

      // 2. Create organization
      const slug = data.organizationName
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-|-$/g, '')

      const { data: org, error: orgError } = await supabase
        .from('organizations')
        .insert({
          name: data.organizationName,
          slug: slug,
          plan: 'free',
          settings: {},
        })
        .select()
        .single()

      if (orgError) throw orgError

      // 3. Link user to organization as owner
      const { error: linkError } = await supabase
        .from('organization_users')
        .insert({
          organization_id: org.id,
          user_id: authData.user.id,
          role: 'owner',
        })

      if (linkError) throw linkError

      // 4. Create initial seed data for the organization
      await createInitialData(org.id)

      toast({
        title: 'Success!',
        description: 'Account created successfully. Welcome!',
      })

      navigate('/dashboard')
    } catch (error) {
      console.error('Signup error:', error)
      toast({
        title: 'Error',
        description: error instanceof Error ? error.message : 'Failed to create account',
        variant: 'destructive',
      })
    } finally {
      setIsLoading(false)
    }
  }

  const login = async (data: LoginData) => {
    setIsLoading(true)
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email: data.email,
        password: data.password,
      })

      if (error) throw error

      toast({
        title: 'Welcome back!',
        description: 'Successfully logged in',
      })

      navigate('/dashboard')
    } catch (error) {
      console.error('Login error:', error)
      toast({
        title: 'Error',
        description: error instanceof Error ? error.message : 'Failed to login',
        variant: 'destructive',
      })
    } finally {
      setIsLoading(false)
    }
  }

  const logout = async () => {
    try {
      const { error } = await supabase.auth.signOut()
      if (error) throw error

      toast({
        title: 'Logged out',
        description: 'Successfully logged out',
      })

      navigate('/login')
    } catch (error) {
      console.error('Logout error:', error)
      toast({
        title: 'Error',
        description: 'Failed to logout',
        variant: 'destructive',
      })
    }
  }

  return {
    signup,
    login,
    logout,
    isLoading,
  }
}

// Helper function to create initial data for new organization
async function createInitialData(organizationId: string) {
  // Create initial products
  await supabase.from('products').insert([
    {
      organization_id: organizationId,
      name: 'Product 1',
      description: 'First product',
      keywords: ['product', 'sample'],
      patterns: {},
      exclusions: [],
      compatibility: [],
      scoring_base: 50,
      priority: 1,
      is_active: true,
    },
    {
      organization_id: organizationId,
      name: 'Product 2',
      description: 'Second product',
      keywords: ['product', 'demo'],
      patterns: {},
      exclusions: [],
      compatibility: [],
      scoring_base: 60,
      priority: 2,
      is_active: true,
    },
  ])

  // Create initial need types
  await supabase.from('need_types').insert([
    {
      organization_id: organizationId,
      name: 'Oferta',
      description: 'Solicitud de presupuesto',
      priority: 10,
      keywords: ['presupuesto', 'cotización', 'precio'],
      is_active: true,
    },
    {
      organization_id: organizationId,
      name: 'Más Información',
      description: 'Consultas generales',
      priority: 5,
      keywords: ['información', 'consulta', 'detalles'],
      is_active: true,
    },
  ])

  // Create initial workflow config
  await supabase.from('workflow_config').insert([
    {
      organization_id: organizationId,
      workflow_name: 'clasificacion_ia',
      is_active: true,
      config: { model: 'gpt-4o' },
    },
  ])
}
