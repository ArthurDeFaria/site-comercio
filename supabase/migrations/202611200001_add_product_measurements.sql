alter table public.produtos
    add column if not exists medidas jsonb not null default '{}'::jsonb;

alter table public.produtos
    drop constraint if exists produtos_medidas_objeto_check;

alter table public.produtos
    add constraint produtos_medidas_objeto_check
    check (jsonb_typeof(medidas) = 'object');
