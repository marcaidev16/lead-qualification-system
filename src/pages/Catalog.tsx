import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Plus, Package } from 'lucide-react'

export function Catalog() {
  return (
    <div className="container mx-auto p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Product Catalog</h1>
          <p className="text-muted-foreground">
            Manage your products and services
          </p>
        </div>
        <Button>
          <Plus className="mr-2 h-4 w-4" />
          Add Product
        </Button>
      </div>

      {/* Empty State */}
      <Card>
        <CardHeader>
          <CardTitle>No products yet</CardTitle>
          <CardDescription>
            Start by adding your first product or service to the catalog
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col items-center justify-center py-12">
          <Package className="h-16 w-16 text-muted-foreground mb-4" />
          <p className="text-muted-foreground text-center mb-4">
            Add products to help classify and match leads automatically
          </p>
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            Add Your First Product
          </Button>
        </CardContent>
      </Card>
    </div>
  )
}
