-- BudgetIQ — Phase 2 migration 0003: transactions
--
-- Separate income and expense transaction tables. Amounts are always positive
-- numeric(14,2); the sign/direction is implied by the table. Category is
-- optional at the DB level (set null on category delete) so deleting a category
-- never destroys financial history.

create table if not exists public.income_transactions (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users (id) on delete cascade,
  category_id  uuid references public.income_categories (id) on delete set null,
  amount       numeric(14,2) not null check (amount > 0),
  currency_code char(3) not null default 'USD',
  occurred_on  date not null,
  note         text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  deleted_at   timestamptz
);

create table if not exists public.expense_transactions (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users (id) on delete cascade,
  category_id  uuid references public.expense_categories (id) on delete set null,
  amount       numeric(14,2) not null check (amount > 0),
  currency_code char(3) not null default 'USD',
  occurred_on  date not null,
  note         text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  deleted_at   timestamptz
);

-- Monthly reporting / dashboard queries filter by user + date.
create index if not exists idx_income_tx_user_date
  on public.income_transactions (user_id, occurred_on desc)
  where deleted_at is null;
create index if not exists idx_expense_tx_user_date
  on public.expense_transactions (user_id, occurred_on desc)
  where deleted_at is null;
create index if not exists idx_income_tx_category
  on public.income_transactions (category_id) where deleted_at is null;
create index if not exists idx_expense_tx_category
  on public.expense_transactions (category_id) where deleted_at is null;

create trigger trg_income_tx_updated_at
  before update on public.income_transactions
  for each row execute function public.set_updated_at();
create trigger trg_expense_tx_updated_at
  before update on public.expense_transactions
  for each row execute function public.set_updated_at();

alter table public.income_transactions enable row level security;
alter table public.expense_transactions enable row level security;

create policy "income_tx owner select" on public.income_transactions
  for select using (auth.uid() = user_id);
create policy "income_tx owner insert" on public.income_transactions
  for insert with check (auth.uid() = user_id);
create policy "income_tx owner update" on public.income_transactions
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "income_tx owner delete" on public.income_transactions
  for delete using (auth.uid() = user_id);

create policy "expense_tx owner select" on public.expense_transactions
  for select using (auth.uid() = user_id);
create policy "expense_tx owner insert" on public.expense_transactions
  for insert with check (auth.uid() = user_id);
create policy "expense_tx owner update" on public.expense_transactions
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "expense_tx owner delete" on public.expense_transactions
  for delete using (auth.uid() = user_id);
