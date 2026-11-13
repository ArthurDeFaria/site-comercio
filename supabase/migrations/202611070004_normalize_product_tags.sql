create table if not exists public.tags (
    id uuid primary key default gen_random_uuid(),
    nome text not null,
    created_at timestamptz not null default now()
);

create unique index if not exists tags_nome_normalizado_key
on public.tags (lower(trim(nome)));

create table if not exists public.produto_tags (
    produto_id uuid not null references public.produtos (id) on delete cascade,
    tag_id uuid not null references public.tags (id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (produto_id, tag_id)
);

insert into public.tags (nome)
select distinct trim(produto_tag.tag)
from public.produtos
    cross join lateral unnest(public.produtos.tags) as produto_tag(tag)
    where trim(produto_tag.tag) <> ''
on conflict (lower(trim(nome))) do nothing;

insert into public.produto_tags (produto_id, tag_id)
select produto.id, tag.id
from public.produtos as produto
    cross join lateral unnest(produto.tags) as produto_tag(nome)
join public.tags as tag
    on lower(trim(tag.nome)) = lower(trim(produto_tag.nome))
on conflict (produto_id, tag_id) do nothing;

alter table public.tags enable row level security;
alter table public.produto_tags enable row level security;

grant select on public.tags to anon, authenticated;
grant insert, update, delete on public.tags to authenticated;
grant select on public.produto_tags to anon, authenticated;
grant insert, update, delete on public.produto_tags to authenticated;

drop policy if exists tags_leitura_publica on public.tags;
create policy tags_leitura_publica
on public.tags for select
to anon, authenticated
using (true);

drop policy if exists tags_gestao_admin on public.tags;
create policy tags_gestao_admin
on public.tags for all
to authenticated
using (public.usuario_admin_autorizado())
with check (public.usuario_admin_autorizado());

drop policy if exists produto_tags_leitura_publica on public.produto_tags;
create policy produto_tags_leitura_publica
on public.produto_tags for select
to anon, authenticated
using (
    exists (
        select 1
        from public.produtos
        where produtos.id = produto_tags.produto_id
          and produtos.ativo = true
    )
);

drop policy if exists produto_tags_gestao_admin on public.produto_tags;
create policy produto_tags_gestao_admin
on public.produto_tags for all
to authenticated
using (public.usuario_admin_autorizado())
with check (public.usuario_admin_autorizado());
