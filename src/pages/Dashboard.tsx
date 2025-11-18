import { useOrganization } from '@/contexts/OrganizationContext'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Users, Package, TrendingUp, Activity } from 'lucide-react'

export function Dashboard() {
  const { organization, userRole } = useOrganization()

  const stats = [
    {
      title: 'Total Leads',
      value: '0',
      description: 'Leads processed',
      icon: Users,
    },
    {
      title: 'Products',
      value: '0',
      description: 'Active products',
      icon: Package,
    },
    {
      title: 'Conversion Rate',
      value: '0%',
      description: 'Last 30 days',
      icon: TrendingUp,
    },
    {
      title: 'Active Workflows',
      value: '0',
      description: 'Running workflows',
      icon: Activity,
    },
  ]

  return (
    <div className="container mx-auto p-6 space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="text-muted-foreground">
          Welcome back, {organization?.name} ({userRole})
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.title}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{stat.title}</CardTitle>
              <stat.icon className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stat.value}</div>
              <p className="text-xs text-muted-foreground">{stat.description}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Placeholder for charts */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="col-span-4">
          <CardHeader>
            <CardTitle>Overview</CardTitle>
            <CardDescription>Lead activity over time</CardDescription>
          </CardHeader>
          <CardContent className="flex items-center justify-center h-64">
            <p className="text-muted-foreground">Chart placeholder - Coming soon</p>
          </CardContent>
        </Card>
        <Card className="col-span-3">
          <CardHeader>
            <CardTitle>Recent Leads</CardTitle>
            <CardDescription>Latest leads processed</CardDescription>
          </CardHeader>
          <CardContent className="flex items-center justify-center h-64">
            <p className="text-muted-foreground">No leads yet</p>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
