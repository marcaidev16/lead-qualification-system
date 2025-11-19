-- ============================================
-- MULTI-TENANT SCHEMA - SAFE VERSION
-- Esta versión maneja elementos existentes
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- CLEANUP: Drop existing policies first
-- ============================================
DROP POLICY IF EXISTS "Admins can manage workflows" ON workflow_config;
DROP POLICY IF EXISTS "Users can view org workflows" ON workflow_config;
DROP POLICY IF EXISTS "Admins can manage leads" ON leads;
DROP POLICY IF EXISTS "Users can create leads" ON leads;
DROP POLICY IF EXISTS "Users can view org leads" ON leads;
DROP POLICY IF EXISTS "Admins can manage need_types" ON need_types;
DROP POLICY IF EXISTS "Users can view org need_types" ON need_types;
DROP POLICY IF EXISTS "Admins can manage products" ON products;
DROP POLICY IF EXISTS "Users can view org products" ON products;
DROP POLICY IF EXISTS "Admins can manage org members" ON organization_users;
DROP POLICY IF EXISTS "Users can view their org members" ON organization_users;
DROP POLICY IF EXISTS "Users can update their organization" ON organizations;
DROP POLICY IF EXISTS "Users can view their organization" ON organizations;

-- Drop old tables if they exist
DROP TABLE IF EXISTS workflow_config CASCADE;
DROP TABLE IF EXISTS leads CASCADE;
DROP TABLE IF EXISTS need_types CASCADE;
DROP TABLE IF EXISTS products CASCADE;

-- ============================================
-- TABLA: organizations (Tenants)
-- ============================================
CREATE TABLE IF NOT EXISTS organizations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'enterprise')),
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

DROP INDEX IF EXISTS idx_organizations_slug;
CREATE INDEX idx_organizations_slug ON organizations(slug);

-- ============================================
-- TABLA: organization_users (Users ↔ Organizations)
-- ============================================
CREATE TABLE IF NOT EXISTS organization_users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'user', 'viewer')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(organization_id, user_id)
);

DROP INDEX IF EXISTS idx_organization_users_org;
DROP INDEX IF EXISTS idx_organization_users_user;
CREATE INDEX idx_organization_users_org ON organization_users(organization_id);
CREATE INDEX idx_organization_users_user ON organization_users(user_id);

-- ============================================
-- TABLA: products (with organization_id)
-- ============================================
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  keywords TEXT[] DEFAULT '{}',
  patterns JSONB DEFAULT '{}',
  exclusions TEXT[] DEFAULT '{}',
  compatibility TEXT[] DEFAULT '{}',
  scoring_base INTEGER DEFAULT 50 CHECK (scoring_base >= 0 AND scoring_base <= 100),
  priority INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_org ON products(organization_id);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_active ON products(is_active);

-- ============================================
-- TABLA: need_types (with organization_id)
-- ============================================
CREATE TABLE need_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  priority INTEGER DEFAULT 5 CHECK (priority >= 1 AND priority <= 10),
  keywords TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_need_types_org ON need_types(organization_id);
CREATE INDEX idx_need_types_name ON need_types(name);

-- ============================================
-- TABLA: leads (with organization_id)
-- ============================================
CREATE TABLE leads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

  -- Datos originales
  full_name TEXT,
  email TEXT,
  company TEXT,
  subject TEXT,
  body TEXT,

  -- Clasificación IA
  tipo_necesidad TEXT,
  subtipo_necesidad TEXT,
  productos_servicios TEXT[] DEFAULT '{}',
  urgencia TEXT,
  sentimiento TEXT,
  scoring INTEGER DEFAULT 0,
  ai_reasoning TEXT,
  palabras_clave_detectadas TEXT[] DEFAULT '{}',
  next_steps_suggested TEXT,

  -- Enrichment
  empresa_verificada BOOLEAN DEFAULT false,
  empresa_nombre_oficial TEXT,
  empresa_cif TEXT,
  empresa_web TEXT,
  empresa_descripcion TEXT,
  empresa_sector TEXT,
  empresa_empleados_rango TEXT,
  empresa_facturacion_estimada TEXT,
  empresa_ciudad TEXT,
  empresa_provincia TEXT,
  empresa_pais TEXT,
  empresa_telefono TEXT,
  empresa_linkedin TEXT,
  lead_email_verificado BOOLEAN DEFAULT false,
  lead_email_score INTEGER DEFAULT 0,
  empresa_stack_tecnologico TEXT[] DEFAULT '{}',
  empresa_madurez_digital TEXT,

  -- Metadatos
  odoo_lead_id INTEGER,
  processed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_leads_org ON leads(organization_id);
CREATE INDEX idx_leads_email ON leads(email);
CREATE INDEX idx_leads_company ON leads(company);
CREATE INDEX idx_leads_scoring ON leads(scoring);
CREATE INDEX idx_leads_created_at ON leads(created_at DESC);

-- Enable Real-time
ALTER TABLE leads REPLICA IDENTITY FULL;

-- ============================================
-- TABLA: workflow_config (with organization_id)
-- ============================================
CREATE TABLE workflow_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  workflow_name TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  config JSONB DEFAULT '{}',
  last_run TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(organization_id, workflow_name)
);

CREATE INDEX idx_workflow_config_org ON workflow_config(organization_id);

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- Helper function to get user's organization
CREATE OR REPLACE FUNCTION auth.user_organization_id()
RETURNS UUID AS $$
  SELECT organization_id FROM organization_users
  WHERE user_id = auth.uid()
  LIMIT 1;
$$ LANGUAGE SQL STABLE;

-- Organizations
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their organization"
  ON organizations FOR SELECT
  USING (id IN (
    SELECT organization_id FROM organization_users WHERE user_id = auth.uid()
  ));

CREATE POLICY "Users can update their organization"
  ON organizations FOR UPDATE
  USING (id IN (
    SELECT organization_id FROM organization_users
    WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
  ));

-- Organization Users
ALTER TABLE organization_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their org members"
  ON organization_users FOR SELECT
  USING (organization_id IN (
    SELECT organization_id FROM organization_users WHERE user_id = auth.uid()
  ));

CREATE POLICY "Admins can manage org members"
  ON organization_users FOR ALL
  USING (organization_id IN (
    SELECT organization_id FROM organization_users
    WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
  ));

-- Products
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view org products"
  ON products FOR SELECT
  USING (organization_id = auth.user_organization_id());

CREATE POLICY "Admins can manage products"
  ON products FOR ALL
  USING (organization_id IN (
    SELECT organization_id FROM organization_users
    WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
  ));

-- Need Types
ALTER TABLE need_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view org need_types"
  ON need_types FOR SELECT
  USING (organization_id = auth.user_organization_id());

CREATE POLICY "Admins can manage need_types"
  ON need_types FOR ALL
  USING (organization_id IN (
    SELECT organization_id FROM organization_users
    WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
  ));

-- Leads
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view org leads"
  ON leads FOR SELECT
  USING (organization_id = auth.user_organization_id());

CREATE POLICY "Users can create leads"
  ON leads FOR INSERT
  WITH CHECK (organization_id = auth.user_organization_id());

CREATE POLICY "Admins can manage leads"
  ON leads FOR ALL
  USING (organization_id IN (
    SELECT organization_id FROM organization_users
    WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
  ));

-- Workflow Config
ALTER TABLE workflow_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view org workflows"
  ON workflow_config FOR SELECT
  USING (organization_id = auth.user_organization_id());

CREATE POLICY "Admins can manage workflows"
  ON workflow_config FOR ALL
  USING (organization_id IN (
    SELECT organization_id FROM organization_users
    WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
  ));

-- ============================================
-- SEED DATA: Create 2 test organizations
-- ============================================
INSERT INTO organizations (name, slug, plan) VALUES
('Future AI', 'future-ai', 'pro'),
('Binovo', 'binovo', 'enterprise')
ON CONFLICT (slug) DO NOTHING;
