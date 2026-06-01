-- =============================================================
-- 방명록(Guestbook) 스키마 + RLS 정책
-- 대상: Supabase (PostgreSQL)
-- 사용법: Supabase 대시보드 → SQL Editor 에 이 파일 내용을 붙여넣고 Run
-- 정책 요약: 누구나 읽기 + 누구나 작성 / 수정·삭제는 불가
-- =============================================================

-- gen_random_uuid() 함수를 위한 확장 (Supabase에는 보통 기본 활성화돼 있음)
create extension if not exists "pgcrypto";

-- -------------------------------------------------------------
-- 1) 테이블
-- -------------------------------------------------------------
create table if not exists public.guestbook (
  id          uuid        primary key default gen_random_uuid(),
  name        text        not null,
  message     text        not null,
  created_at  timestamptz not null default now(),

  -- 빈 값/공백만 입력 방지 + 길이 제한 (스팸·악용 1차 방어)
  constraint guestbook_name_len    check (char_length(trim(name))    between 1 and 40),
  constraint guestbook_message_len check (char_length(trim(message)) between 1 and 500)
);

comment on table  public.guestbook            is '방명록 항목';
comment on column public.guestbook.id         is '고유 ID (자동 생성)';
comment on column public.guestbook.name       is '작성자 이름 (1~40자)';
comment on column public.guestbook.message    is '메시지 내용 (1~500자)';
comment on column public.guestbook.created_at is '작성 시간 (서버 기준, 자동 입력)';

-- 최신순(created_at DESC) 목록 조회 성능을 위한 인덱스
create index if not exists guestbook_created_at_idx
  on public.guestbook (created_at desc);

-- -------------------------------------------------------------
-- 2) RLS(Row Level Security) 활성화
--    → 활성화하면 정책(policy)에 명시된 동작만 허용됨.
--      정책이 없는 동작(UPDATE/DELETE)은 자동으로 모두 거부.
-- -------------------------------------------------------------
alter table public.guestbook enable row level security;

-- 누구나 읽기 (로그인 안 한 anon 포함)
create policy "Anyone can read guestbook"
  on public.guestbook
  for select
  to anon, authenticated
  using (true);

-- 누구나 작성
create policy "Anyone can insert guestbook"
  on public.guestbook
  for insert
  to anon, authenticated
  with check (true);

-- ※ UPDATE / DELETE 정책은 일부러 만들지 않습니다.
--   → RLS에 의해 모든 수정·삭제가 거부되어, 작성된 글의 변조/삭제를 막습니다.
--   (운영자만 삭제하고 싶다면 service_role 키를 쓰는 서버에서 처리하세요.)

-- -------------------------------------------------------------
-- 3) (권장) created_at·id 위조 방지 — 컬럼 단위 권한
--    클라이언트가 INSERT 할 때 name, message 두 컬럼만 넣도록 제한.
--    id / created_at 은 항상 DB 기본값(default)으로 채워져 위조 불가.
-- -------------------------------------------------------------
revoke insert on public.guestbook from anon, authenticated;
grant  insert (name, message) on public.guestbook to anon, authenticated;
