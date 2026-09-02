-- BudgetIQ — Phase 2 migration 0002: categories
--
-- Separate income and expense category tables (per Phase 0 schema design).
-- Each row is owned by a user; system defaults are seeded per-user on sign-up
-- and are editable like any other category.

create table if not exists public.income_categories (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  name        text not null check (char_length(trim(name)) > 0),
  icon        text,
  color       text,
  is_system   boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create table if not exists public.expense_categories (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  name        text not null check (char_length(trim(name)) > 0),
  icon        text,
  color       text,
  is_system   boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

-- Active (non-deleted) categories per user are looked up frequently.
create index if not exists idx_income_categories_user
  on public.income_categories (user_id) where deleted_at is null;
create index if not exists idx_expense_categories_user
  on public.expense_categories (user_id) where deleted_at is null;

create trigger trg_income_categories_updated_at
  before update on public.income_categories
  for each row execute function public.set_updated_at();
create trigger trg_expense_categories_updated_at
  before update on public.expense_categories
  for each row execute function public.set_updated_at();

alter table public.income_categories enable row level security;
alter table public.expense_categories enable row level security;

-- Owner-only access. One policy per action keeps intent explicit.
create policy "income_categories owner select" on public.income_categories
  for select using (auth.uid() = user_id);
create policy "income_categories owner insert" on public.income_categories
  for insert with check (auth.uid() = user_id);
create policy "income_categories owner update" on public.income_categories
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "income_categories owner delete" on public.income_categories
  for delete using (auth.uid() = user_id);

create policy "expense_categories owner select" on public.expense_categories
  for select using (auth.uid() = user_id);
create policy "expense_categories owner insert" on public.expense_categories
  for insert with check (auth.uid() = user_id);
create policy "expense_categories owner update" on public.expense_categories
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "expense_categories owner delete" on public.expense_categories
  for delete using (auth.uid() = user_id);
