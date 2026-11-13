-- Revoga perfis administrativos que ficaram sem uma conta correspondente no Auth.
-- Isso impede que uma sessão antiga continue autorizada por um perfil órfão.
update public.perfis_admin as perfil
set ativo = false
where not exists (
    select 1
    from auth.users as usuario
    where usuario.id = perfil.user_id
);

-- A autorização também exige que a conta ainda exista no Auth. Isso protege contra
-- sessões antigas caso a remoção da conta e a remoção do perfil não ocorram juntas.
create or replace function public.usuario_admin_autorizado()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
    select exists (
        select 1
        from public.perfis_admin as perfil
        join auth.users as usuario on usuario.id = perfil.user_id
        where perfil.user_id = auth.uid()
          and perfil.ativo = true
    );
$$;

create or replace function public.usuario_admin_principal()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
    select exists (
        select 1
        from public.perfis_admin as perfil
        join auth.users as usuario on usuario.id = perfil.user_id
        where perfil.user_id = auth.uid()
          and perfil.ativo = true
          and perfil.administrador_principal = true
    );
$$;
