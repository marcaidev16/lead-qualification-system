# Create Page Command

Create a new page component with React Query integration.

## Usage
```
/create-page PageName
```

## Page Template

```tsx
import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { useOrganization } from '@/contexts/OrganizationContext'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

export function PageName() {
  const { organization } = useOrganization()

  const { data, isLoading, error } = useQuery({
    queryKey: ['page-data', organization.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('table_name')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      return data
    },
    enabled: !!organization.id
  })

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    )
  }

  if (error) {
    return (
      <Card className="border-destructive">
        <CardHeader>
          <CardTitle>Error</CardTitle>
          <CardDescription>Failed to load data</CardDescription>
        </CardHeader>
      </Card>
    )
  }

  return (
    <div className="container mx-auto p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Page Title</h1>
          <p className="text-muted-foreground">Page description</p>
        </div>
        <Button>Action</Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Content</CardTitle>
        </CardHeader>
        <CardContent>
          {/* Page content */}
        </CardContent>
      </Card>
    </div>
  )
}
```

## Guidelines

1. **File Location:** `src/pages/{PageName}.tsx`

2. **Always include:**
   - Loading state
   - Error state
   - Empty state
   - Header with title and actions
   - Container with proper spacing

3. **Data fetching:**
   - Use React Query
   - Include organization.id in queryKey
   - Enable query only when org exists
   - Handle errors gracefully

4. **Layout:**
   - Use container for max-width
   - Consistent padding (p-6)
   - Proper spacing (space-y-6)
   - Mobile-first responsive

5. **RLS automatic:**
   - Don't filter by organization_id manually
   - RLS policies handle it automatically
