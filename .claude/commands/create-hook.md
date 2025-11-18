# Create Hook Command

Create a custom React hook following the project patterns.

## Usage
```
/create-hook hookName
```

## Hook Template

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { useOrganization } from '@/contexts/OrganizationContext'
import { toast } from '@/components/ui/use-toast'

export function useHookName() {
  const { organization } = useOrganization()
  const queryClient = useQueryClient()

  // Query
  const { data, isLoading, error } = useQuery({
    queryKey: ['hook-data', organization.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('table_name')
        .select('*')

      if (error) throw error
      return data
    },
    enabled: !!organization.id
  })

  // Mutation
  const createMutation = useMutation({
    mutationFn: async (newItem: any) => {
      const { data, error } = await supabase
        .from('table_name')
        .insert({
          organization_id: organization.id,
          ...newItem
        })
        .select()
        .single()

      if (error) throw error
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries(['hook-data'])
      toast({
        title: 'Success',
        description: 'Item created successfully'
      })
    },
    onError: (error) => {
      toast({
        title: 'Error',
        description: error.message,
        variant: 'destructive'
      })
    }
  })

  return {
    data,
    isLoading,
    error,
    create: createMutation.mutate,
    isCreating: createMutation.isPending
  }
}
```

## Guidelines

1. **File Location:** `src/hooks/{hookName}.ts`

2. **Naming:**
   - Always start with `use` prefix
   - camelCase: `useLeads`, `useProducts`, `useAuth`

3. **Return object:**
   - Expose data, loading states, errors
   - Expose mutation functions with clear names
   - Include loading states for mutations

4. **Always include:**
   - Organization context
   - React Query for data fetching
   - Toast notifications for success/error
   - Query invalidation after mutations

5. **Multi-tenant:**
   - Always include organization.id in queries
   - Always add organization_id when creating records
   - Enable queries only when organization exists

6. **Error handling:**
   - Throw errors from queries (React Query catches them)
   - Show toast on mutation errors
   - Return error state for components to handle

## Common Hook Patterns

**Data fetching hook:**
```tsx
export function useItems() {
  const { organization } = useOrganization()

  return useQuery({
    queryKey: ['items', organization.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('items')
        .select('*')
      if (error) throw error
      return data
    }
  })
}
```

**CRUD hook:**
```tsx
export function useItemsCRUD() {
  const { organization } = useOrganization()
  const queryClient = useQueryClient()

  const create = useMutation({...})
  const update = useMutation({...})
  const remove = useMutation({...})

  return { create, update, remove }
}
```
