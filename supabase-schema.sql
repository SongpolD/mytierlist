-- Run once in the Supabase SQL Editor after replacing OWNER_EMAIL in this script.
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table if not exists private.app_owners (
  email text primary key
);
revoke all on private.app_owners from public, anon, authenticated;

insert into private.app_owners (email) values ('OWNER_EMAIL')
on conflict (email) do nothing;

create or replace function public.is_app_owner()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from private.app_owners
    where lower(email) = lower((select auth.jwt() ->> 'email'))
  );
$$;
revoke all on function public.is_app_owner() from public, anon;
grant execute on function public.is_app_owner() to authenticated;

create table if not exists public.top10_items (
  id uuid primary key default gen_random_uuid(),
  position integer not null,
  name text not null,
  kind text not null check (kind in ('หนัง', 'ซีรีส์', 'อนิเมะ')),
  image text not null default ''
);

alter table public.top10_items enable row level security;
grant select on public.top10_items to anon, authenticated;
grant insert, update, delete on public.top10_items to authenticated;

drop policy if exists "Anyone can view the top 10" on public.top10_items;
create policy "Anyone can view the top 10"
  on public.top10_items for select to anon, authenticated using (true);

drop policy if exists "Only owner can add items" on public.top10_items;
create policy "Only owner can add items"
  on public.top10_items for insert to authenticated
  with check ((select public.is_app_owner()));

drop policy if exists "Only owner can edit items" on public.top10_items;
create policy "Only owner can edit items"
  on public.top10_items for update to authenticated
  using ((select public.is_app_owner()))
  with check ((select public.is_app_owner()));

drop policy if exists "Only owner can delete items" on public.top10_items;
create policy "Only owner can delete items"
  on public.top10_items for delete to authenticated
  using ((select public.is_app_owner()));

-- Run this only when the table is empty; it seeds the starter examples from data.json.
insert into public.top10_items (position, name, kind, image)
select d.position, d.name, d.kind, d.image
from (values
  (1, 'Kaguya-sama: Love Is War', 'อนิเมะ', 'https://cdn.myanimelist.net/images/anime/1295/106551l.jpg'),
  (2, 'Rascal Does Not Dream of Bunny Girl Senpai', 'อนิเมะ', 'https://cdn.myanimelist.net/images/anime/1613/102179l.jpg'),
  (3, 'Angel Beats!', 'อนิเมะ', 'https://cdn.myanimelist.net/images/anime/1244/111115l.jpg'),
  (4, 'Your Lie in April', 'อนิเมะ', 'https://cdn.myanimelist.net/images/anime/3/67177l.jpg'),
  (5, 'A Silent Voice', 'หนัง', 'https://cdn.myanimelist.net/images/anime/1122/96435l.jpg'),
  (6, 'Horimiya', 'อนิเมะ', 'https://cdn.myanimelist.net/images/anime/1695/111486l.jpg')
) as d(position, name, kind, image)
where not exists (select 1 from public.top10_items);
