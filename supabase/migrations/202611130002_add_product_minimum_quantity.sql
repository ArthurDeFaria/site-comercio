alter table public.produtos
    add column if not exists quantidade_minima integer not null default 10;

alter table public.produtos
    drop constraint if exists produtos_quantidade_minima_check;

alter table public.produtos
    add constraint produtos_quantidade_minima_check check (quantidade_minima >= 1);
