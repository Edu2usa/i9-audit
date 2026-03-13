-- ═══════════════════════════════════════════════════════════════
-- Preferred Maintenance – I9 Audit Table
-- Run this in your Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS employees_i9 (
    id               bigint generated always as identity primary key,

    -- Basic employee info
    last_name        text not null,
    first_name       text not null,
    middle_initial   text,
    hire_date        date,
    department       text,
    position         text,

    -- I-9 completion
    i9_complete      boolean default false,
    i9_date          date,          -- date employer signed Section 2

    -- Document choice: 'A' = List A only, 'BC' = List B + List C
    doc_list         text check (doc_list in ('A','BC')),

    -- List A document (establishes both identity & work authorization)
    doc_a_type       text,
    doc_a_number     text,
    doc_a_issuer     text,
    doc_a_expiry     date,

    -- List B document (identity only)
    doc_b_type       text,
    doc_b_number     text,
    doc_b_issuer     text,
    doc_b_expiry     date,

    -- List C document (work authorization only)
    doc_c_type       text,
    doc_c_number     text,
    doc_c_issuer     text,
    doc_c_expiry     date,

    -- Section 3 – Re-verification
    reverify_needed  boolean default false,
    reverify_by      date,
    reverify_done    boolean default false,
    reverify_doc_type   text,
    reverify_doc_number text,
    reverify_doc_expiry date,

    notes            text,
    created_at       timestamptz default now(),
    updated_at       timestamptz default now()
);

-- Enable Row Level Security
ALTER TABLE employees_i9 ENABLE ROW LEVEL SECURITY;

-- Allow anonymous access (same pattern as equipment tracker)
CREATE POLICY "anon_all_i9" ON employees_i9
    FOR ALL TO anon
    USING (true)
    WITH CHECK (true);

-- Auto-update updated_at on any row change
CREATE OR REPLACE FUNCTION touch_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$;

CREATE TRIGGER employees_i9_updated_at
    BEFORE UPDATE ON employees_i9
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
