-- BudgetIQ — Phase 2 migration 0001: profiles
--
-- One profile row per auth user, created automatically on sign-up. Holds
-- single-currency and presentation preferences. RLS restricts every row to its
-- owner.

create extension if not exists "pgcrypto";

-- Generic updated_at trigger reused across tables.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id            uuid primary key references auth.users (id) on delete cascade,
  display_name  text,
  currency_code char(3) not null default 'USD',
  locale        text not null default 'en_US',
  theme_mode    text not null default 'system'
                  check (theme_mode in ('system', 'light', 'dark')),
  large_text    boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;

create policy "Profiles are viewable by owner"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Profiles are insertable by owner"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Profiles are updatable by owner"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);
