----------------------------------------------------------------
--                          Config                              --
----------------------------------------------------------------
ALTER ROLE authenticator SET pgrst.db_aggregates_enabled = 'true';
NOTIFY pgrst, 'reload config';

-- Estensioni
create extension if not exists pgcrypto schema extensions;
create extension if not exists moddatetime schema extensions;

----------------------------------------------------------------
--                          Storage                             --
----------------------------------------------------------------
delete from storage.objects where bucket_id = 'gare';
delete from storage.buckets where id = 'gare';

drop policy if exists "Public access for all users" on storage.objects;
drop policy if exists "User can upload in their own folders" on storage.objects;
drop policy if exists "User can update their own objects" on storage.objects;
drop policy if exists "User can delete their own objects" on storage.objects;

insert into storage.buckets (id, name, public) values ('gare', 'gare', true);

create policy "Public access for all users" on storage.objects
  for select to authenticated, anon using (bucket_id = 'gare');
create policy "User can upload in their own folders" on storage.objects
  for insert to authenticated with check (bucket_id = 'gare' and (storage.foldername(name))[1] = (select auth.uid()::text));
create policy "User can update their own objects" on storage.objects
  for update to authenticated using (owner_id = (select auth.uid()::text));
create policy "User can delete their own objects" on storage.objects
  for delete to authenticated using (owner_id = (select auth.uid()::text));

----------------------------------------------------------------
--                       Reset/Drop                             --
----------------------------------------------------------------
-- Drop triggers
drop trigger if exists on_created on auth.users;
drop trigger if exists on_encrypted_password_updated on auth.users;
drop trigger if exists on_updated_at on users;
drop trigger if exists on_username_updated on users;
drop trigger if exists on_role_updated on users;
drop trigger if exists on_plan_updated on users;
drop trigger if exists on_updated_at on role_permissions;
drop trigger if exists on_updated_at on emails;
drop trigger if exists on_updated_at on notifications;
drop trigger if exists on_updated_at on votes;
drop trigger if exists on_updated_at on favorites;
drop trigger if exists on_slug_upsert on posts;
drop trigger if exists on_updated_at on posts;
drop trigger if exists on_created on posts;
drop trigger if exists on_updated_at on tags;
drop trigger if exists on_slug_upsert on tags;

-- Drop functions
drop function if exists generate_password;
drop function if exists generate_username;
drop function if exists handle_has_set_password;
drop function if exists verify_user_password;
drop function if exists handle_new_user;
drop function if exists create_new_user;
drop function if exists delete_user;
drop function if exists assign_user_data;
drop function if exists handle_username_changed_at;
drop function if exists handle_role_changed_at;
drop function if exists handle_plan_changed_at;
drop function if exists set_user_role;
drop function if exists set_user_plan;
drop function if exists set_user_meta;
drop function if exists get_users;
drop function if exists set_post_tags;
drop function if exists set_tag_meta;
drop function if exists unique_tag_slug;
drop function if exists generate_tag_slug;
drop function if exists set_tag;
drop function if exists set_statistics;
drop function if exists truncate_statistics;
drop function if exists get_post_rank_by_views;
drop function if exists get_vote;
drop function if exists set_favorite;
drop function if exists set_post_meta;
drop function if exists set_post_views;
drop function if exists unique_post_slug;
drop function if exists generate_post_slug;
drop function if exists count_posts;
drop function if exists get_adjacent_post_id;
drop function if exists create_new_posts;
drop function if exists handle_new_post;
drop function if exists truncate_posts;
drop function if exists title_description;
drop function if exists title_keywords;
drop function if exists title_content;
drop function if exists title_description_keywords;
drop function if exists title_description_content;

-- Drop tables in ordine corretto (dall'ultimo al primo per le dipendenze)
drop table if exists statistics;
drop table if exists post_tags;
drop table if exists tagmeta;
drop table if exists tags;
drop table if exists votes;
drop table if exists favorites;
drop table if exists postmeta;
drop table if exists posts;
drop table if exists notifications;
drop table if exists emails;
drop table if exists role_permissions;
drop table if exists usermeta;
drop table if exists users;


----------------------------------------------------------------
--                     Creazione Tabelle                        --
----------------------------------------------------------------

-- 1. Tabella users (tabella base)
create table users (
  id uuid not null references auth.users on delete cascade primary key,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  deleted_at timestamptz,
  email varchar(255),
  full_name text,
  first_name text,
  last_name text,
  age integer,
  avatar_url text,
  website text,
  bio text,
  username text not null,
  username_changed_at timestamptz,
  has_set_password boolean default false not null,
  is_ban boolean default false not null,
  banned_until timestamptz,
  role text default 'guest'::text not null,
  role_changed_at timestamptz,
  plan text default 'free'::text not null,
  plan_changed_at timestamptz,
  unique (username)
);

create index users_username_idx on users (username);
create index users_role_idx on users (role);
create index users_plan_idx on users (plan);

comment on column users.updated_at is 'on_updated_at';
comment on column users.username_changed_at is 'on_username_updated';
comment on column users.has_set_password is 'on_encrypted_password_updated';
comment on column users.role is 'guest, user, admin, superadmin';
comment on column users.role_changed_at is 'on_role_updated';
comment on column users.plan is 'free, basic, standard, premium';
comment on column users.plan_changed_at is 'on_plan_updated';

-- 2. Tabella usermeta
create table usermeta (
  id bigint generated by default as identity primary key,
  user_id uuid references users(id) on delete cascade not null,
  meta_key varchar(255) not null,
  meta_value text,
  unique(user_id, meta_key)
);

create index usermeta_user_id_idx on usermeta (user_id);
create index usermeta_meta_key_idx on usermeta (meta_key);

-- 3. Tabella role_permissions
create table role_permissions (
  id bigint generated by default as identity primary key,
  role text not null,
  permission text not null,
  unique (role, permission)
);

-- 4. Tabella emails
create table emails (
  id bigint generated by default as identity primary key,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  user_id uuid references users(id) on delete cascade not null,
  email varchar(255) not null,
  email_confirmed_at timestamptz,
  unique (user_id, email)
);

create index emails_user_id_idx on emails (user_id);
create index emails_email_idx on emails (email);

-- 5. Tabella notifications
create table notifications (
  id bigint generated by default as identity primary key,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  user_id uuid references users(id) on delete cascade not null,
  marketing_emails boolean default false not null,
  security_emails boolean default true not null
);

create index notifications_user_id_idx on notifications (user_id);

-- 6. Tabella posts
create table posts (
  id bigint generated by default as identity primary key,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  deleted_at timestamptz,
  date timestamptz,
  user_id uuid references users(id) on delete cascade not null,
  type text default 'post'::text not null,
  status text default 'draft'::text not null,
  password varchar(255),
  title text,
  slug text,
  description text,
  keywords text,
  content text,
  thumbnail_url text,
  permalink text,
  is_ban boolean default false not null,
  banned_until timestamptz
);

create index posts_slug_idx on posts (slug);
create index posts_type_status_date_idx on posts (type, status, date, id);
create index posts_user_id_idx on posts (user_id);
create index posts_user_id_slug_idx on posts (user_id, slug);

comment on column posts.updated_at is 'on_updated_at';
comment on column posts.slug is 'on_slug_upsert';
comment on column posts.type is 'post, page, revision';
comment on column posts.status is 'publish, future, draft, pending, private, trash';

-- 7. Tabella postmeta
create table postmeta (
  id bigint generated by default as identity primary key,
  post_id bigint references posts(id) on delete cascade not null,
  meta_key varchar(255) not null,
  meta_value text,
  unique(post_id, meta_key)
);

create index postmeta_post_id_idx on postmeta (post_id);
create index postmeta_meta_key_idx on postmeta (meta_key);

-- 8. Tabella favorites
create table favorites (
  id bigint generated by default as identity primary key,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  user_id uuid references users(id) on delete cascade not null,
  post_id bigint references posts(id) on delete cascade not null,
  is_favorite boolean default false not null,
  unique (user_id, post_id)
);

create index favorites_user_id_idx on favorites (user_id);
create index favorites_post_id_idx on favorites (post_id);

-- 9. Tabella votes
create table votes (
  id bigint generated by default as identity primary key,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  user_id uuid references users(id) on delete cascade not null,
  post_id bigint references posts(id) on delete cascade not null,
  is_like smallint default 0 not null,
  is_dislike smallint default 0 not null,
  unique (user_id, post_id)
);

create index votes_user_id_idx on votes (user_id);
create index votes_post_id_idx on votes (post_id);

-- 10. Tabella tags
create table tags (
  id bigint generated by default as identity primary key,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  user_id uuid references users(id) on delete cascade not null,
  name text,
  slug text,
  description text
);

create index tags_name_idx on tags (name);
create index tags_slug_idx on tags (slug);
create index tags_user_id_idx on tags (user_id);
create index tags_user_id_name_idx on tags (user_id, name);
create index tags_user_id_slug_idx on tags (user_id, slug);

-- 11. Tabella tagmeta
create table tagmeta (
  id bigint generated by default as identity primary key,
  tag_id bigint references tags(id) on delete cascade not null,
  meta_key varchar(255) not null,
  meta_value text,
  unique (tag_id, meta_key)
);

create index tagmeta_tag_id_idx on tagmeta (tag_id);
create index tagmeta_meta_key_idx on tagmeta (meta_key);

-- 12. Tabella post_tags
create table post_tags (
  id bigint generated by default as identity primary key,
  user_id uuid references users(id) on delete cascade not null,
  post_id bigint references posts(id) on delete cascade not null,
  tag_id bigint references tags(id) on delete cascade not null,
  unique (user_id, post_id, tag_id)
);

create index post_tags_user_id_idx on post_tags (user_id);
create index post_tags_post_id_idx on post_tags (post_id);
create index post_tags_tag_id_idx on post_tags (tag_id);
create index post_tags_user_id_post_id_idx on post_tags (user_id, post_id);

-- 13. Tabella statistics
create table statistics (
  id bigint generated by default as identity primary key,
  created_at timestamptz default now() not null,
  visitor_id uuid not null,
  user_id uuid references users(id) on delete cascade,
  title text,
  location text,
  path text,
  query text,
  referrer text,
  ip inet,
  browser jsonb,
  user_agent text
);

create index statistics_visitor_id_idx on statistics (visitor_id);
create index statistics_user_id_idx on statistics (user_id);

----------------------------------------------------------------
--                  Funzioni di Base                           --
----------------------------------------------------------------

create or replace function generate_password()
returns text
security definer set search_path = public
as $$
begin
  return trim(both from (encode(decode(md5(random()::text || current_timestamp || random()),'hex'),'base64')), '=');
end;
$$ language plpgsql;

----------------------------------------------------------------
--                   Funzioni Rimanenti                         --
----------------------------------------------------------------

create or replace function generate_username(email text)
returns text
security definer set search_path = public
as $$
declare
  new_username text;
  username_exists boolean;
begin
  new_username := lower(split_part(email, '@', 1));
  select exists(select 1 from users where username = new_username) into username_exists;

  while username_exists loop
    new_username := new_username || '_' || to_char(trunc(random()*1000000), 'fm000000');
    select exists(select 1 from users where username = new_username) into username_exists;
  end loop;

  return new_username;
end;
$$ language plpgsql;

----------------------------------------------------------------

create or replace function create_new_user(useremail text, password text = null, metadata JSONB = '{}'::JSONB)
returns uuid
as $$
declare
  user_id uuid;
  encrypted_pw text;
  app_metadata jsonb;
begin
  select id into user_id from auth.users where email = useremail;

  if user_id is null then
    user_id := gen_random_uuid();
    encrypted_pw := crypt(password, gen_salt('bf'));
    app_metadata := '{"provider":"email","providers":["email"]}'::jsonb || metadata::jsonb;

    insert into auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, confirmation_sent_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
    values
    ('00000000-0000-0000-0000-000000000000', user_id, 'authenticated', 'authenticated', useremail, encrypted_pw, now(), now(), now(), now(), app_metadata, '{}', now(), now(), '', '', '', '');

    insert into auth.identities
    (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
    values
    (gen_random_uuid(), user_id, format('{"sub":"%s","email":"%s"}', user_id::text, useremail)::jsonb, 'email', now(), now(), now());
  end if;

  return user_id;
end;
$$ language plpgsql;

----------------------------------------------------------------

create or replace function handle_new_user()
returns trigger
security definer set search_path = public
as $$
declare
  new_username text;
  new_has_set_password boolean;
begin
  new_username := generate_username(new.email);
  new_username := substr(new_username, 1, 255);
  new_has_set_password := case when new.encrypted_password is null or new.encrypted_password = '' then false else true end;

  insert into users
  (id, has_set_password, username, full_name, avatar_url)
  values
  (new.id, new_has_set_password, new_username, new_username, new.raw_user_meta_data ->> 'avatar_url');
  insert into emails (user_id, email) values (new.id, new.email);
  insert into notifications (user_id) values (new.id);

  return new;
end;
$$ language plpgsql;

create or replace function create_new_user(useremail text, password text = null, metadata JSONB = '{}'::JSONB)
returns uuid
as $$
declare
  user_id uuid;
  encrypted_pw text;
  app_metadata jsonb;
begin
  select id into user_id from auth.users where email = useremail;

  if user_id is null then
    user_id := gen_random_uuid();
    encrypted_pw := crypt(password, gen_salt('bf'));
    app_metadata := '{"provider":"email","providers":["email"]}'::jsonb || metadata::jsonb;

    insert into auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, confirmation_sent_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
    values
    ('00000000-0000-0000-0000-000000000000', user_id, 'authenticated', 'authenticated', useremail, encrypted_pw, now(), now(), now(), now(), app_metadata, '{}', now(), now(), '', '', '', '');

    insert into auth.identities
    (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
    values
    (gen_random_uuid(), user_id, format('{"sub":"%s","email":"%s"}', user_id::text, useremail)::jsonb, 'email', now(), now(), now());
  end if;

  return user_id;
end;
$$ language plpgsql;

----------------------------------------------------------------

create trigger on_created 
after insert on auth.users
for each row 
execute procedure handle_new_user();

----------------------------------------------------------------

create or replace function assign_user_data()
returns void
security definer set search_path = public
as $$
declare
  r record;
  new_username text;
  new_has_set_password boolean;
begin
  for r in (select * from auth.users) loop
    if not exists (select 1 from users where id = r.id) then
      new_username := generate_username(r.email);
      new_username := substr(new_username, 1, 255);
      new_has_set_password := case when r.encrypted_password is null or r.encrypted_password = '' then false else true end;
      insert into users (id, has_set_password, username, full_name, avatar_url) 
      values (r.id, new_has_set_password, new_username, new_username, r.raw_user_meta_data ->> 'avatar_url');
      insert into emails (user_id, email) values (r.id, r.email);
      insert into notifications (user_id) values (r.id);
    end if;
  end loop;
end;
$$ language plpgsql;

----------------------------------------------------------------
--                    Row Level Security                        --
----------------------------------------------------------------

-- RLS per users
alter table users enable row level security;
create policy "Public access for all users" on users for select to authenticated, anon using ( true );
create policy "User can insert their own users" on users for insert to authenticated with check ( (select auth.uid()) = id );
create policy "User can update their own users" on users for update to authenticated using ( (select auth.uid()) = id );
create policy "User can delete their own users" on users for delete to authenticated using ( (select auth.uid()) = id );

-- RLS per usermeta
alter table usermeta enable row level security;
create policy "Public access for all users" on usermeta for select to authenticated, anon using ( true );
create policy "User can insert their own usermeta" on usermeta for insert to authenticated with check ( (select auth.uid()) = user_id );
create policy "User can update their own usermeta" on usermeta for update to authenticated using ( (select auth.uid()) = user_id );
create policy "User can delete their own usermeta" on usermeta for delete to authenticated using ( (select auth.uid()) = user_id );

-- RLS per role_permissions
alter table role_permissions enable row level security;
create policy "Public access for all users" on role_permissions for select to authenticated, anon using ( true );

-- Applica RLS simili per le altre tabelle...

----------------------------------------------------------------
--                       Creazione Utente Test                  --
----------------------------------------------------------------

select create_new_user('bandigare@gmail.com', 'Wolfgang-75');
select assign_user_data();
select set_user_role('superadmin', null, 'bandigare@gmail.com');
select set_user_plan('premium', null, 'bandigare@gmail.com');