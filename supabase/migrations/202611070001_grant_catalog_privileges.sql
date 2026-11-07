grant select on public.produtos to anon, authenticated;
grant insert, update, delete on public.produtos to authenticated;

grant select on public.precos_decoracao to anon, authenticated;
grant insert, update, delete on public.precos_decoracao to authenticated;
grant usage, select on sequence public.precos_decoracao_id_seq to authenticated;

grant select, insert, update, delete on public.perfis_admin to authenticated;