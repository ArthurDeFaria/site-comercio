create table if not exists public.portfolio_projetos (
    id uuid primary key default gen_random_uuid(),
    titulo text not null,
    descricao text not null default '',
    imagem_path text not null,
    ordem integer not null default 0 check (ordem >= 0),
    ativo boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

drop trigger if exists portfolio_projetos_atualizar_updated_at on public.portfolio_projetos;
create trigger portfolio_projetos_atualizar_updated_at
before update on public.portfolio_projetos
for each row execute function public.atualizar_updated_at();

alter table public.portfolio_projetos enable row level security;
grant select on public.portfolio_projetos to anon, authenticated;
grant insert, update, delete on public.portfolio_projetos to authenticated;

drop policy if exists portfolio_leitura_publica on public.portfolio_projetos;
create policy portfolio_leitura_publica
on public.portfolio_projetos for select
to anon, authenticated
using (ativo = true);

drop policy if exists portfolio_gestao_admin on public.portfolio_projetos;
create policy portfolio_gestao_admin
on public.portfolio_projetos for all
to authenticated
using (public.usuario_admin_autorizado())
with check (public.usuario_admin_autorizado());
