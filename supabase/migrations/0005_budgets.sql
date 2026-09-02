-- BudgetIQ — Phase 3 migration 0005: budgets
--
-- Monthly, category-based budgets. One budget per user per month
-- (period_start = first day of the month). Each budget allocates an amount to
-- expense categories; "spent" is derived at read time from expense
-- transactions, never stored, to avoid duplicated financial data.

create table if not exists public.budgets (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  period_start  date not null,
  total_amount  numeric(14,2) not null default 0 check (total_amount >= 0),
  currency_code char(3) not null default 'USD',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz,
  -- One active budget per month per user.
  constraint budgets_user_period_unique unique (user_id, period_start)
);

create table if not exists public.budget_categories (
  id                  uuid primary key default gen_random_uuid(),
  budget_id           uuid not null references public.budgets (id) on delete cascade,
  expense_category_id uuid not null references public.expense_categories (id) on delete cascade,
  allocated_amount    numeric(14,2) not null check (allocated_amount >= 0),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  -- A category appears at most once per budget.
  constraint budget_categories_unique unique (budget_id, expense_category_id)
);

create index if not exists idx_budgets_user
  on public.budgets (user_id, period_start desc) where deleted_at is null;
create index if not exists idx_budget_categories_budget
  on public.budget_categories (budget_id);

create trigger trg_budgets_updated_at
  before update on public.budgets
  for each row execute function public.set_updated_at();
create trigger trg_budget_categories_updated_at
  before update on public.budget_categories
  for each row execute function public.set_updated_at();

alter table public.budgets enable row level security;
alter table public.budget_categories enable row level security;

create policy "budgets owner select" on public.budgets
  for select using (auth.uid() = user_id);
create policy "budgets owner insert" on public.budgets
  for insert with check (auth.uid() = user_id);
create policy "budgets owner update" on public.budgets
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "budgets owner delete" on public.budgets
  for delete using (auth.uid() = user_id);

-- budget_categories are reachable only through a budget the user owns.
create policy "budget_categories owner select" on public.budget_categories
  for select using (exists (
    select 1 from public.budgets b
    where b.id = budget_id and b.user_id = auth.uid()
  ));
create policy "budget_categories owner insert" on public.budget_categories
  for insert with check (exists (
    select 1 from public.budgets b
    where b.id = budget_id and b.user_id = auth.uid()
  ));
create policy "budget_categories owner update" on public.budget_categories
  for update using (exists (
    select 1 from public.budgets b
    where b.id = budget_id and b.user_id = auth.uid()
  ));
create policy "budget_categories owner delete" on public.budget_categories
  for delete using (exists (
    select 1 from public.budgets b
    where b.id = budget_id and b.user_id = auth.uid()
  ));
