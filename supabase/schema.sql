-- Dead Air Broadcasting Cooperative: database setup.
-- Run this once in Supabase: SQL Editor → New query → paste → Run.
-- Safe to run again; it only (re)creates the same rules.

-- 1. Content table -----------------------------------------------------------
create table if not exists public.entries (
  area text not null check (area in ('air', 'desk')),          -- air = published, desk = owner's drafts
  kind text not null check (kind in ('stations', 'broadcasts', 'staff', 'notices', 'singles')),
  id   text not null check (id ~ '^[A-Za-z0-9_-]{1,80}$'),
  data jsonb not null default '{}'::jsonb check (pg_column_size(data) < 262144),
  updated_at timestamptz not null default now(),
  primary key (area, kind, id)
);

-- 2. Who owns the station ------------------------------------------------------
create table if not exists public.site_owner (
  only_one boolean primary key default true check (only_one),
  email text not null
);

-- No API access at all to site_owner (no policies = nobody can read or change it from the web).
alter table public.site_owner enable row level security;
alter table public.entries enable row level security;

create or replace function public.is_owner()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    auth.role() = 'authenticated'
    and lower(auth.jwt() ->> 'email') = (select lower(email) from public.site_owner limit 1),
    false);
$$;
revoke all on function public.is_owner() from public;
grant execute on function public.is_owner() to anon, authenticated;

-- 3. Rules for content ---------------------------------------------------------
drop policy if exists "visitors read published" on public.entries;
drop policy if exists "owner reads everything"  on public.entries;
drop policy if exists "owner adds"              on public.entries;
drop policy if exists "owner changes"           on public.entries;
drop policy if exists "owner removes"           on public.entries;

create policy "visitors read published" on public.entries
  for select to anon, authenticated using (area = 'air');
create policy "owner reads everything" on public.entries
  for select to authenticated using (public.is_owner());
create policy "owner adds" on public.entries
  for insert to authenticated with check (public.is_owner());
create policy "owner changes" on public.entries
  for update to authenticated using (public.is_owner()) with check (public.is_owner());
create policy "owner removes" on public.entries
  for delete to authenticated using (public.is_owner());

grant select on public.entries to anon;
grant select, insert, update, delete on public.entries to authenticated;

-- 4. Image storage (public to view; only the owner can upload) -------------------
-- Server-side limits: images only (PNG, JPEG, WebP, GIF), 8 MB per file.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('station-images', 'station-images', true, 8388608,
        array['image/png', 'image/jpeg', 'image/webp', 'image/gif'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "owner uploads station images" on storage.objects;
drop policy if exists "owner replaces station images" on storage.objects;
drop policy if exists "owner removes station images" on storage.objects;

create policy "owner uploads station images" on storage.objects
  for insert to authenticated with check (bucket_id = 'station-images' and public.is_owner());
create policy "owner replaces station images" on storage.objects
  for update to authenticated using (bucket_id = 'station-images' and public.is_owner());
create policy "owner removes station images" on storage.objects
  for delete to authenticated using (bucket_id = 'station-images' and public.is_owner());
