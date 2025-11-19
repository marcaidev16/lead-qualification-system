import { Link, useLocation } from 'react-router-dom'
import { LayoutDashboard, Users, Package, Workflow, Settings, LogOut } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { useAuth } from '@/hooks/useAuth'
import { useOrganization } from '@/contexts/OrganizationContext'

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Leads', href: '/leads', icon: Users },
  { name: 'Catalog', href: '/catalog', icon: Package },
  { name: 'Workflows', href: '/workflows', icon: Workflow },
]

export function Sidebar() {
  const location = useLocation()
  const { logout } = useAuth()
  const { organization, userRole } = useOrganization()

  return (
    <div className="flex h-full w-64 flex-col border-r bg-background">
      {/* Logo / Org Name */}
      <div className="flex h-16 items-center border-b px-6">
        <h1 className="text-xl font-bold text-primary">Lead Qualifier</h1>
      </div>

      {/* Organization Info */}
      {organization && (
        <div className="border-b px-6 py-4">
          <p className="text-sm font-medium">{organization.name}</p>
          <p className="text-xs text-muted-foreground capitalize">{userRole} • {organization.plan}</p>
        </div>
      )}

      {/* Navigation */}
      <nav className="flex-1 space-y-1 px-3 py-4">
        {navigation.map((item) => {
          const isActive = location.pathname === item.href
          return (
            <Link
              key={item.name}
              to={item.href}
              className={cn(
                'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                isActive
                  ? 'bg-primary text-primary-foreground'
                  : 'text-muted-foreground hover:bg-muted hover:text-foreground'
              )}
            >
              <item.icon className="h-5 w-5" />
              {item.name}
            </Link>
          )
        })}
      </nav>

      {/* Footer */}
      <div className="border-t p-3 space-y-1">
        <Link
          to="/settings"
          className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
        >
          <Settings className="h-5 w-5" />
          Settings
        </Link>
        <Button
          variant="ghost"
          className="w-full justify-start text-muted-foreground hover:text-foreground"
          onClick={() => logout()}
        >
          <LogOut className="mr-3 h-5 w-5" />
          Logout
        </Button>
      </div>
    </div>
  )
}
