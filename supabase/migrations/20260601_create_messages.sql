-- =============================================================
-- 방명록 messages 테이블 + RLS 정책
-- 대상: Supabase (PostgreSQL)
-- 사용법: Supabase 대시보드 → SQL Editor 에 붙여넣고 Run
-- 정책: 누구나 읽기(SELECT) + 누구나 쓰기(INSERT) / 수정·삭제는 불가
-- =============================================================

create extension if not exists "pgcrypto";  -- gen_random_uuid() 용

-- -------------------------------------------------------------
-- 1) 테이블 (id, name, content, created_at)
-- -------------------------------------------------------------
create table if not exists public.messages (
  id          uuid        primary key default gen_random_uuid(),
  name        text        not null,
  content     text        not null,
  created_at  timestamptz not null default now(),

  -- 빈 값/공백만 입력 방지 + 길이 제한 (스팸·도배 1차 방어)
  constraint messages_name_len    check (char_length(trim(name))    between 1 and 40),
  constraint messages_content_len check (char_length(trim(content)) between 1 and 500)
);

comment on table  public.messages            is '방명록 메시지';
comment on column public.messages.name       is '작성자 이름 (1~40자)';
comment on column public.messages.content    is '메시지 내용 (1~500자)';
comment on column public.messages.created_at is '작성 시간 (서버 기준, 자동)';

-- 최신순 목록 조회 최적화
create index if not exists messages_created_at_idx
  on public.messages (created_at desc);

-- -------------------------------------------------------------
-- 2) RLS 활성화 — 정책에 없는 동작(UPDATE/DELETE)은 자동 거부
-- -------------------------------------------------------------
alter table public.messages enable row level security;

-- 역할 권한 명시 (Supabase 기본값과 무관하게 동작하도록)
grant select on public.messages to anon, authenticated;

-- 누구나 읽기
create policy "Anyone can read messages"
  on public.messages
  for select
  to anon, authenticated
  using (true);

-- 누구나 쓰기(작성)
create policy "Anyone can insert messages"
  on public.messages
  for insert
  to anon, authenticated
  with check (true);

-- ※ 수정/삭제 정책 없음 → 남이 글을 바꾸거나 지울 수 없음(변조 방지).
--   운영자 삭제가 필요하면 service_role 키를 쓰는 서버에서 처리하세요.

-- -------------------------------------------------------------
-- 3) (권장) id·created_at 위조 방지 — 클라이언트는 name, content만 입력 가능
-- -------------------------------------------------------------
revoke insert on public.messages from anon, authenticated;
grant  insert (name, content) on public.messages to anon, authenticated;
