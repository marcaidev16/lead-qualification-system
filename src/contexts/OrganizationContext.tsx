import { createContext, useContext, useEffect, useState } from 'react'
import type { ReactNode } from 'react'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import type { Organization, UserRole } from '@/types/database.types'

interface OrganizationContextType {
  organization: Organization | null
  userRole: UserRole | null
  isOwner: boolean
  isAdmin: boolean
  isLoading: boolean
  error: Error | null
  refetch: () => void
}

const OrganizationContext = createContext<OrganizationContextType | undefined>(undefined)

interface OrganizationProviderProps {
  children: ReactNode
}

export function OrganizationProvider({ children }: OrganizationProviderProps) {
  const [userId, setUserId] = useState<string | null>(null)

  // Get current user
  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUserId(session?.user?.id || null)
    })

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUserId(session?.user?.id || null)
    })

    return () => subscription.unsubscribe()
  }, [])

  // Fetch user's organization and role
  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['user-organization', userId],
    queryFn: async () => {
      if (!userId) throw new Error('No user ID')

      // Get user's organization membership
      const { data: orgUser, error: orgUserError } = await supabase
        .from('organization_users')
        .select('*, organizations(*)')
        .eq('user_id', userId)
        .single()

      if (orgUserError) throw orgUserError
      if (!orgUser) throw new Error('User not associated with any organization')

      return {
        organization: orgUser.organizations as unknown as Organization,
        userRole: orgUser.role as UserRole,
      }
    },
    enabled: !!userId,
    retry: 1,
  })

  const organization = data?.organization || null
  const userRole = data?.userRole || null
  const isOwner = userRole === 'owner'
  const isAdmin = userRole === 'owner' || userRole === 'admin'

  return (
    <OrganizationContext.Provider
      value={{
        organization,
        userRole,
        isOwner,
        isAdmin,
        isLoading,
        error: error as Error | null,
        refetch,
      }}
    >
      {children}
    </OrganizationContext.Provider>
  )
}

export function useOrganization() {
  const context = useContext(OrganizationContext)
  if (context === undefined) {
    throw new Error('useOrganization must be used within an OrganizationProvider')
  }
  return context
}
