# Database Migrations

Este directorio contiene las migraciones de la base de datos para el Lead Qualification System.

## Migraciones Disponibles

### 001_initial_schema.sql
Esquema inicial completo con las siguientes tablas:
- **products**: Catálogo de productos/servicios
- **need_types**: Tipos de necesidades de los leads
- **leads**: Datos de leads con clasificación IA y enrichment
- **workflow_config**: Configuración de workflows automatizados

## Cómo Aplicar las Migraciones

### Opción 1: Usando Supabase Dashboard (Recomendado para primera vez)

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com)
2. En el menú lateral, selecciona **SQL Editor**
3. Haz clic en **+ New query**
4. Copia y pega el contenido de `001_initial_schema.sql`
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

Después de aplicar la migración, verifica:

1. **Tablas creadas**: Ve a Table Editor y verifica que existan:
   - products
   - need_types
   - leads
   - workflow_config

2. **Datos de ejemplo**: Verifica que las tablas tengan datos iniciales:
   - products: 3 productos (agenticHUB, n8n, Consultoría IA)
   - need_types: 3 tipos (Oferta, Más Información, Otros)
   - workflow_config: 2 workflows

3. **Políticas RLS**: Ve a Authentication → Policies y verifica que existan políticas para cada tabla

## Rollback (Si algo sale mal)

Si necesitas revertir cambios:

```sql
-- Ejecuta esto en SQL Editor
DROP TABLE IF EXISTS workflow_config CASCADE;
DROP TABLE IF EXISTS leads CASCADE;
DROP TABLE IF EXISTS need_types CASCADE;
DROP TABLE IF EXISTS products CASCADE;
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
