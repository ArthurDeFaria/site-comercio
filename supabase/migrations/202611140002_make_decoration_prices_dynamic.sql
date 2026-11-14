alter table public.precos_decoracao
    drop constraint if exists precos_decoracao_quantidade_check,
    drop constraint if exists precos_decoracao_cores_check;

alter table public.precos_decoracao
    add constraint precos_decoracao_quantidade_check check (quantidade >= 1),
    add constraint precos_decoracao_cores_check check (cores >= 1);
