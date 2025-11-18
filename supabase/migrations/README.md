# Database Migrations

Este directorio contiene las migraciones de la base de datos para el Lead Qualification System.

## Migraciones Disponibles

### ⚠️ 001_initial_schema.sql (DEPRECATED)
**NO USAR** - No incluye multi-tenancy. Usar 002_multi_tenant_schema.sql en su lugar.

### ✅ 002_multi_tenant_schema.sql (RECOMENDADO)
**Esquema completo multi-tenant** con las siguientes tablas:
- **organizations**: Tenants (organizaciones)
- **organization_users**: Relación usuarios ↔ organizaciones con roles
- **products**: Catálogo de productos/servicios (con organization_id)
- **need_types**: Tipos de necesidades (con organization_id)
- **leads**: Datos de leads con clasificación IA (con organization_id)
- **workflow_config**: Configuración de workflows (con organization_id)

**Características:**
- ✅ Complete data isolation via RLS
- ✅ Role-based access control (owner/admin/user/viewer)
- ✅ Helper function `auth.user_organization_id()`
- ✅ 2 test organizations pre-created (Future AI, Binovo)
- ✅ Foreign key constraints
- ✅ Proper indexes for performance

## Cómo Aplicar las Migraciones

### Opción 1: Usando Supabase Dashboard (Recomendado para primera vez)

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com/project/oiulcqkdlzwtghdvajgh)
2. En el menú lateral, selecciona **SQL Editor**
3. Haz clic en **+ New query**
4. Copia y pega el contenido de `002_multi_tenant_schema.sql`
5. Haz clic en **Run** (o presiona Ctrl/Cmd + Enter)
6. Verifica que todas las tablas se hayan creado correctamente en la sección **Table Editor**

### Opción 2: Usando Supabase CLI

Si tienes el CLI instalado y configurado:

```bash
# Aplicar todas las migraciones pendientes
npx supabase db push

# O aplicar una migración específica manualmente
npx supabase db execute --file supabase/migrations/001_initial_schema.sql
```

### Opción 3: Usando psql (Avanzado)

Si tienes acceso directo a PostgreSQL:

```bash
psql "postgresql://postgres:yRXX3SfANqzhhP1i@db.oiulcqkdlzwtghdvajgh.supabase.co:5432/postgres" \
  -f supabase/migrations/001_initial_schema.sql
```

## Verificar la Migración

Después de aplicar la migración `002_multi_tenant_schema.sql`, verifica:

1. **Tablas creadas**: Ve a Table Editor y verifica que existan:
   - organizations
   - organization_users
   - products
   - need_types
   - leads
   - workflow_config

2. **Organizaciones de prueba**: Verifica que existan:
   - organizations: 2 organizaciones (Future AI, Binovo)

3. **Función helper**: En SQL Editor ejecuta:
   ```sql
   SELECT auth.user_organization_id();
   ```

4. **Políticas RLS**: Ve a Authentication → Policies y verifica que existan políticas para cada tabla con filtrado por organization_id

## Rollback (Si algo sale mal)

Si necesitas revertir cambios de la migración 002:

```sql
-- Ejecuta esto en SQL Editor
DROP TABLE IF EXISTS workflow_config CASCADE;
DROP TABLE IF EXISTS leads CASCADE;
DROP TABLE IF EXISTS need_types CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS organization_users CASCADE;
DROP TABLE IF EXISTS organizations CASCADE;
DROP FUNCTION IF EXISTS auth.user_organization_id();
```

## Próximas Migraciones

Para crear nuevas migraciones:

1. Crea un archivo con el siguiente formato: `002_nombre_descriptivo.sql`
2. Asegúrate de que el número sea secuencial
3. Incluye tanto la migración UP como instrucciones de rollback en comentarios
4. Documenta los cambios en este README

## Notas Importantes

- ⚠️ **NUNCA** edites una migración que ya haya sido aplicada en producción
- ✅ Siempre prueba las migraciones en un entorno de desarrollo primero
- 📝 Documenta cualquier cambio manual que hagas en la base de datos
- 🔐 Las políticas RLS están configuradas de forma básica para MVP - ajustar en producción
