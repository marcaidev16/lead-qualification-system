#!/bin/bash

echo "======================================"
echo "LEAD QUALIFICATION SYSTEM"
echo "Apply Multi-Tenant Database Migration"
echo "======================================"
echo ""
echo "Migration: 002_multi_tenant_schema.sql"
echo ""
echo "Steps to apply:"
echo ""
echo "1. Open Supabase Dashboard:"
echo "   https://app.supabase.com/project/oiulcqkdlzwtghdvajgh/sql"
echo ""
echo "2. Click '+ New query'"
echo ""
echo "3. Copy the migration SQL:"
echo "   cat supabase/migrations/002_multi_tenant_schema.sql | pbcopy"
echo "   (or manually copy from: supabase/migrations/002_multi_tenant_schema.sql)"
echo ""
echo "4. Paste into SQL Editor and click 'Run'"
echo ""
echo "5. Verify tables were created in Table Editor"
echo ""
echo "======================================"
echo "What this migration creates:"
echo "======================================"
echo "✓ organizations (tenants)"
echo "✓ organization_users (user-org relationships with roles)"
echo "✓ products (with organization_id)"
echo "✓ need_types (with organization_id)"
echo "✓ leads (with organization_id)"
echo "✓ workflow_config (with organization_id)"
echo "✓ RLS policies for complete data isolation"
echo "✓ Helper function: auth.user_organization_id()"
echo "✓ 2 test organizations: Future AI, Binovo"
echo ""
echo "Ready to copy SQL? Press Enter..."
read

# Try to copy to clipboard (works on macOS)
if command -v pbcopy &> /dev/null; then
    cat supabase/migrations/002_multi_tenant_schema.sql | pbcopy
    echo "✓ SQL copied to clipboard!"
    echo "Now paste it in Supabase SQL Editor and Run"
else
    echo "Copy manually from: supabase/migrations/002_multi_tenant_schema.sql"
fi

echo ""
echo "Opening Supabase Dashboard..."
# Try to open browser (works on macOS and Linux)
if command -v open &> /dev/null; then
    open "https://app.supabase.com/project/oiulcqkdlzwtghdvajgh/sql"
elif command -v xdg-open &> /dev/null; then
    xdg-open "https://app.supabase.com/project/oiulcqkdlzwtghdvajgh/sql"
fi
