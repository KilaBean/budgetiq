-- BudgetIQ — migration 0007: soft delete for budget_categories
--
-- Adds deleted_at so budget allocations follow the same soft-delete pattern as
-- every other entity, letting the offline sync engine delete them uniformly.

alter table public.budget_categories
  add column if not exists deleted_at timestamptz;

-- Active allocations per budget are looked up frequently.
create index if not exists idx_budget_categories_active
  on public.budget_categories (budget_id) where deleted_at is null;
