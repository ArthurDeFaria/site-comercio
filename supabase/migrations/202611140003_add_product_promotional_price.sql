alter table public.produtos
    add column if not exists preco_promocional numeric(10, 2);

alter table public.produtos
    drop constraint if exists produtos_preco_promocional_check;

alter table public.produtos
    add constraint produtos_preco_promocional_check check (preco_promocional is null or preco_promocional > 0);
