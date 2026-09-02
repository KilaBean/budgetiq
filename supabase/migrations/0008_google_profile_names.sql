-- BudgetIQ — migration 0008: better display names for OAuth sign-ups
--
-- Google sign-up carries the user's real name in raw_user_meta_data, so prefer
-- it over the email local-part that email/password sign-ups fall back to.
-- Replaces the profile insert inside handle_new_user; the category seeding and
-- the on_auth_user_created trigger are unchanged.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_display_name text;
begin
  v_display_name := nullif(trim(coalesce(
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'name',
    ''
  )), '');

  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(v_display_name, split_part(new.email, '@', 1))
  )
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
