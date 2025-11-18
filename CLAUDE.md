# Lead Qualification System - Multi-tenant SaaS

## 🎯 Project Overview
Multi-tenant lead qualification system with AI-powered enrichment.

**Multi-tenancy**: Multiple organizations share the app with complete data isolation via Supabase RLS.

## 🏗️ Tech Stack
- Frontend: React 18 + TypeScript + Vite
- UI: Tailwind CSS + shadcn/ui (Radix primitives)
- Backend: Supabase (PostgreSQL + RLS + Auth + Realtime)
- State: React Query (server) + Zustand (client)
- Forms: React Hook Form + Zod

## 🗄️ Database Schema (Multi-tenant)

**Core Tables:**
- `organizations` - Tenants (slug, plan, settings)
- `organization_users` - Users ↔ Orgs with roles (owner/admin/user/viewer)
- `products` - Catálogo (with organization_id FK)
- `need_types` - Tipos de necesidad (with organization_id FK)
- `leads` - Leads procesados (with organization_id FK)
- `workflow_config` - Config workflows (with organization_id FK)

**RLS Policies:**
- Users only see data from their organization
- Automatic filtering via `auth.user_organization_id()`
- Admins can manage, users can view

## 📁 Project Structure
```
src/
├── components/
│   ├── ui/          # shadcn/ui (no tocar)
│   ├── layout/      # Sidebar, Header, Layout
│   ├── leads/       # Lead components
│   ├── catalog/     # Catalog components
│   └── dashboard/   # Dashboard components
├── pages/           # Route pages
├── hooks/           # Custom hooks
├── stores/          # Zustand stores
├── contexts/        # React contexts
├── lib/             # Utils + Supabase
└── types/           # TypeScript types
```

## 🔐 Multi-tenant Flow

**Signup:**
1. User creates account (Supabase Auth)
2. User creates organization (or accepts invite)
3. User linked to org with role 'owner'
4. Initial data created (products, need_types)

**Login:**
1. User authenticates (Supabase Auth)
2. OrganizationContext loads user's org
3. All queries automatically filtered by organization_id (RLS)

**Key Context:**
- OrganizationContext provides: `organization`, `userRole`, `isAdmin`, `isOwner`

## 🎨 Component Guidelines

**Always use shadcn/ui:**
```tsx
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
```

**Component Structure:**
```tsx
// 1. Imports
import { useState } from 'react'

// 2. Types
interface Props {
  title: string
}

// 3. Component
export function Component({ title }: Props) {
  // Hooks
  const { organization } = useOrganization()

  // Handlers
  const handleClick = () => {}

  // Render
  return <div>{title}</div>
}
```

## 🔄 Data Fetching Pattern

**React Query for all Supabase queries:**
```tsx
const { data, isLoading } = useQuery({
  queryKey: ['leads'],
  queryFn: async () => {
    const { data, error } = await supabase
      .from('leads')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error
    return data
    // RLS automatically filters by organization_id!
  }
})
```

**Mutations:**
```tsx
const createMutation = useMutation({
  mutationFn: async (newLead) => {
    const { data, error } = await supabase
      .from('leads')
      .insert({
        organization_id: organization.id, // Include org_id
        ...newLead
      })
      .select()
      .single()

    if (error) throw error
    return data
  },
  onSuccess: () => {
    queryClient.invalidateQueries(['leads'])
    toast.success('Lead creado!')
  }
})
```

## ⚠️ Critical Rules

- **TypeScript strict mode** - no `any` types
- **Mobile-first** - responsive desde 320px
- **Tailwind only** - no CSS modules
- **Always include organization_id** when creating records
- **RLS handles filtering** - don't filter by org_id manually in queries
- **Toast for errors** - user-friendly messages
- **Loading states** - skeleton or spinner
- **Empty states** - helpful message + CTA

## 🔑 Environment Variables
```
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

## 📚 Common Patterns

**Check if user is admin:**
```tsx
const { isAdmin } = useOrganization()

{isAdmin && <Button>Admin Only Action</Button>}
```

**Get current org:**
```tsx
const { organization } = useOrganization()

console.log(organization.name) // "Future AI"
```

**Realtime subscription:**
```tsx
useEffect(() => {
  const channel = supabase
    .channel('leads-changes')
    .on('postgres_changes',
      { event: 'INSERT', schema: 'public', table: 'leads' },
      (payload) => {
        // New lead arrived
        queryClient.invalidateQueries(['leads'])
      }
    )
    .subscribe()

  return () => supabase.removeChannel(channel)
}, [])
```

## 🎯 MVP Features (Priority Order)
1. ✅ Auth (Signup with org creation, Login, Logout)
2. ✅ Organization Context
3. ✅ Dashboard (KPIs + chart)
4. ✅ Leads (table + filters + detail modal)
5. ✅ Products CRUD
6. ✅ Workflows control

## 🚨 Debugging

**If RLS blocks query:**
1. Check user is authenticated: `supabase.auth.getUser()`
2. Check user has org: query `organization_users`
3. Check RLS policy matches query type (SELECT/INSERT/UPDATE/DELETE)

**If org_id missing:**
- Always include `organization_id: organization.id` when creating records

---

When in doubt, ASK before making decisions!
