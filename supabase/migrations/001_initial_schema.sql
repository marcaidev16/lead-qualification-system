-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLA: products (Productos/Servicios)
-- ============================================
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_active ON products(is_active);

-- ============================================
-- TABLA: need_types (Tipos de Necesidad)
-- ============================================
CREATE TABLE need_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  priority INTEGER DEFAULT 5 CHECK (priority >= 1 AND priority <= 10),
  keywords TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_need_types_name ON need_types(name);

-- ============================================
-- TABLA: leads (Leads Procesados)
-- ============================================
CREATE TABLE leads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

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

CREATE INDEX idx_leads_email ON leads(email);
CREATE INDEX idx_leads_company ON leads(company);
CREATE INDEX idx_leads_scoring ON leads(scoring);
CREATE INDEX idx_leads_created_at ON leads(created_at DESC);

-- Enable Real-time
ALTER TABLE leads REPLICA IDENTITY FULL;

-- ============================================
-- TABLA: workflow_config
-- ============================================
CREATE TABLE workflow_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workflow_name TEXT NOT NULL UNIQUE,
  is_active BOOLEAN DEFAULT true,
  config JSONB DEFAULT '{}',
  last_run TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY (Básico para MVP)
-- ============================================
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE need_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_config ENABLE ROW LEVEL SECURITY;

-- Permitir lectura pública (ajustar en producción)
CREATE POLICY "Allow public read products" ON products FOR SELECT USING (true);
CREATE POLICY "Allow public read need_types" ON need_types FOR SELECT USING (true);
CREATE POLICY "Allow public read leads" ON leads FOR SELECT USING (true);
CREATE POLICY "Allow public read workflow_config" ON workflow_config FOR SELECT USING (true);

-- Permitir escritura autenticada
CREATE POLICY "Allow authenticated insert products" ON products FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated update products" ON products FOR UPDATE USING (auth.role() = 'authenticated');

-- Repetir para otras tablas según sea necesario

-- ============================================
-- SEED DATA
-- ============================================
INSERT INTO products (name, description, keywords, scoring_base, priority) VALUES
('agenticHUB', 'Plataforma colaborativa de IA', ARRAY['agentichub', 'plataforma IA', 'agentes'], 75, 10),
('n8n', 'Automatización y orquestación', ARRAY['n8n', 'automatización', 'workflows'], 70, 9),
('Consultoría IA', 'Servicios de consultoría en IA', ARRAY['consultoría IA', 'asesoría'], 80, 10);

INSERT INTO need_types (name, description, priority, keywords) VALUES
('Oferta', 'Solicitud de presupuesto', 10, ARRAY['presupuesto', 'cotización', 'precio']),
('Más Información', 'Consultas generales', 5, ARRAY['información', 'consulta', 'detalles']),
('Otros', 'Otros intereses', 3, ARRAY['colaboración', 'soporte']);

INSERT INTO workflow_config (workflow_name, is_active, config) VALUES
('clasificacion_ia', true, '{"model": "gpt-4o"}'),
('email_diario', true, '{"schedule": "0 8 * * *"}');
