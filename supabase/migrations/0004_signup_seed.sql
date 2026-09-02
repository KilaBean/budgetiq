-- BudgetIQ — Phase 2 migration 0004: sign-up seeding
--
-- On new auth user creation, create their profile row and seed a starter set of
-- system income/expense categories so the app is usable immediately. Runs with
-- definer rights to bypass RLS during the trigger.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, split_part(new.email, '@', 1))
  on conflict (id) do nothing;

  insert into public.income_categories (user_id, name, icon, is_system)
  values
    (new.id, 'Salary',      'payments',        true),
    (new.id, 'Freelance',   'work',            true),
    (new.id, 'Investments', 'trending_up',     true),
    (new.id, 'Gifts',       'card_giftcard',   true),
    (new.id, 'Other',       'more_horiz',      true);

  insert into public.expense_categories (user_id, name, icon, is_system)
  values
    (new.id, 'Food & Dining', 'restaurant',          true),
    (new.id, 'Transport',     'directions_car',      true),
    (new.id, 'Housing',       'home',                true),
    (new.id, 'Utilities',     'bolt',                true),
    (new.id, 'Shopping',      'shopping_bag',        true),
    (new.id, 'Health',        'favorite',            true),
    (new.id, 'Entertainment', 'movie',               true),
    (new.id, 'Other',         'more_horiz',          true);

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
