-- Migration: 000003_create_organizations

CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    org_type VARCHAR(32) NOT NULL, -- NGO, VET_HOSPITAL, SHELTER, RESCUE_SQUAD
    description TEXT,
    address TEXT NOT NULL,
    location geography(Point, 4326) NOT NULL,
    phone VARCHAR(32) NOT NULL,
    emergency_phone VARCHAR(32),
    website TEXT,
    operating_hours TEXT,
    is_24_7 BOOLEAN NOT NULL DEFAULT FALSE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    facilities TEXT[] NOT NULL DEFAULT '{}', -- AMBULANCE, ICU, SURGERY, OPD, BOARDING
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_organizations_location ON organizations USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_organizations_type ON organizations (org_type, is_24_7);

CREATE TABLE IF NOT EXISTS organization_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    service_name VARCHAR(100) NOT NULL,
    description TEXT
);

