alter table public.produtos
    add column if not exists ordem integer not null default 0;

alter table public.produtos
    drop constraint if exists produtos_ordem_check;

alter table public.produtos
    add constraint produtos_ordem_check
    check (ordem >= 0);
