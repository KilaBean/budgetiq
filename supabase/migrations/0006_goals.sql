-- BudgetIQ — Phase 3 migration 0006: goals
--
-- Savings goals with a target amount and optional deadline. Progress is the sum
-- of contributions (append-only facts), computed at read time.

create table if not exists public.goals (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  name          text not null check (char_length(trim(name)) > 0),
  target_amount numeric(14,2) not null check (target_amount > 0),
  target_date   date,
  currency_code char(3) not null default 'USD',
  status        text not null default 'active'
                  check (status in ('active', 'met', 'archived')),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

create table if not exists public.goal_contributions (
  id          uuid primary key default gen_random_uuid(),
  goal_id     uuid not null references public.goals (id) on delete cascade,
  user_id     uuid not null references auth.users (id) on delete cascade,
  amount      numeric(14,2) not null check (amount > 0),
  occurred_on date not null,
  note        text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create index if not exists idx_goals_user
  on public.goals (user_id) where deleted_at is null;
create index if not exists idx_goal_contributions_goal
  on public.goal_contributions (goal_id, occurred_on) where deleted_at is null;

create trigger trg_goals_updated_at
  before update on public.goals
  for each row execute function public.set_updated_at();
create trigger trg_goal_contributions_updated_at
  before update on public.goal_contributions
  for each row execute function public.set_updated_at();

alter table public.goals enable row level security;
alter table public.goal_contributions enable row level security;

create policy "goals owner select" on public.goals
  for select using (auth.uid() = user_id);
create policy "goals owner insert" on public.goals
  for insert with check (auth.uid() = user_id);
create policy "goals owner update" on public.goals
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "goals owner delete" on public.goals
  for delete using (auth.uid() = user_id);

create policy "goal_contributions owner select" on public.goal_contributions
  for select using (auth.uid() = user_id);
create policy "goal_contributions owner insert" on public.goal_contributions
  for insert with check (auth.uid() = user_id);
create policy "goal_contributions owner update" on public.goal_contributions
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "goal_contributions owner delete" on public.goal_contributions
  for delete using (auth.uid() = user_id);
