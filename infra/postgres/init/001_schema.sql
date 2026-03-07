create extension if not exists pgcrypto;

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  role text not null default 'admin',
  created_at timestamptz not null default now()
);

create table if not exists cases (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  title text not null,
  client_name text not null,
  status text not null default 'draft',
  risk_level text not null default 'medium',
  facts jsonb not null default '{}'::jsonb,
  checklist jsonb not null default '[]'::jsonb,
  supervisor_review jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  actor text not null default 'system',
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_cases_status on cases(status);
create index if not exists idx_cases_risk_level on cases(risk_level);
create index if not exists idx_audit_logs_entity on audit_logs(entity_type, entity_id);
