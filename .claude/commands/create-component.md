# Create Component Command

Create a new React component following the project patterns.

## Usage
```
/create-component ComponentName [folder]
```

## Component Template

```tsx
import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { useOrganization } from '@/contexts/OrganizationContext'

interface ComponentNameProps {
  // Add props here
}

export function ComponentName({}: ComponentNameProps) {
  const { organization, isAdmin } = useOrganization()
  const [isLoading, setIsLoading] = useState(false)

  return (
    <Card>
      <CardHeader>
        <CardTitle>Component Title</CardTitle>
        <CardDescription>Component description</CardDescription>
      </CardHeader>
      <CardContent>
        {/* Component content */}
      </CardContent>
    </Card>
  )
}
```

## Guidelines

1. **File Location:**
   - Feature components: `src/components/{feature}/{ComponentName}.tsx`
   - Shared components: `src/components/{ComponentName}.tsx`
   - UI components: `src/components/ui/{component-name}.tsx` (shadcn only)

2. **Naming:**
   - PascalCase for component name and file
   - Props interface: `{ComponentName}Props`

3. **Structure:**
   - Imports first
   - Interface/types
   - Component function
   - Export at bottom

4. **Always use:**
   - shadcn/ui components
   - TypeScript strict mode
   - Tailwind CSS for styling
   - `useOrganization` hook for multi-tenant context

5. **Include:**
   - Loading states
   - Error handling
   - Empty states
   - Mobile-responsive design
