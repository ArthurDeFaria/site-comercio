alter table public.produtos
    drop constraint if exists produtos_preco_promocional_check;

alter table public.produtos
    add constraint produtos_preco_promocional_check
    check (preco_promocional is null or (preco_promocional > 0 and preco_promocional < preco_peca_branca));
