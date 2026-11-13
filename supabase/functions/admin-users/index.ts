import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
	'Access-Control-Allow-Origin': '*',
	'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
	'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (body: unknown, status = 200) =>
	new Response(JSON.stringify(body), {
		status,
		headers: { ...corsHeaders, 'Content-Type': 'application/json' },
	});

const errorMessage = (error: unknown) =>
	error instanceof Error
		? error.message
		: typeof error === 'object' && error !== null
			? JSON.stringify(error)
			: String(error);

const supabaseUrl = Deno.env.get('SUPABASE_URL');
const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
const appUrl = (Deno.env.get('APP_URL') ?? 'http://localhost:4321').replace(/\/+$/, '');
const isStrongPassword = (password: string) =>
	password.length >= 8 && /[A-Z]/.test(password) && /\d/.test(password) && /[^A-Za-z0-9]/.test(password);
const passwordRequirement = 'A senha deve ter pelo menos 8 caracteres, uma letra maiúscula, um número e um caractere especial.';

if (!supabaseUrl || !anonKey || !serviceRoleKey) {
	throw new Error('Variáveis obrigatórias da Edge Function não configuradas.');
}

const serviceClient = createClient(supabaseUrl, serviceRoleKey, {
	auth: { autoRefreshToken: false, persistSession: false },
});

Deno.serve(async (request) => {
	if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
	if (request.method !== 'POST') return json({ error: 'Método não permitido.' }, 405);

	try {
		const authorization = request.headers.get('Authorization');
		if (!authorization?.startsWith('Bearer ')) return json({ error: 'Autenticação obrigatória.' }, 401);

		const userClient = createClient(supabaseUrl, anonKey, {
			global: { headers: { Authorization: authorization } },
			auth: { autoRefreshToken: false, persistSession: false },
		});
		const { data: userData, error: userError } = await userClient.auth.getUser();
		if (userError || !userData.user) return json({ error: 'Sessão inválida.' }, 401);

		const { data: principal, error: principalError } = await serviceClient
			.from('perfis_admin')
			.select('user_id')
			.eq('user_id', userData.user.id)
			.eq('ativo', true)
			.eq('administrador_principal', true)
			.maybeSingle();
		if (principalError) throw principalError;
		if (!principal) return json({ error: 'Apenas o administrador principal pode gerenciar usuários.' }, 403);

		const payload = await request.json() as { action?: string; email?: string; password?: string; mustChangePassword?: boolean; userId?: string };
		if (payload.action === 'list') {
			const { data: profiles, error: profilesError } = await serviceClient
				.from('perfis_admin')
				.select('user_id, administrador_principal, ativo, created_at')
				.order('created_at');
			if (profilesError) throw profilesError;
			const { data: users, error: usersError } = await serviceClient.auth.admin.listUsers({ page: 1, perPage: 1000 });
			if (usersError) throw usersError;
			return json({
				users: (profiles ?? []).map((profile) => ({
					...profile,
					email: users.users.find((user) => user.id === profile.user_id)?.email ?? 'E-mail indisponível',
				})),
			});
		}

		if (payload.action === 'invite') {
			const email = payload.email?.trim().toLowerCase();
			if (!email || !email.includes('@')) return json({ error: 'Informe um e-mail válido.' }, 400);
			const { data: invited, error: inviteError } = await serviceClient.auth.admin.inviteUserByEmail(email, {
				redirectTo: `${appUrl}/admin`,
				data: { must_change_password: true },
			});
			if (inviteError) throw inviteError;
			const { error: profileError } = await serviceClient.from('perfis_admin').upsert({ user_id: invited.user.id, ativo: true, administrador_principal: false });
			if (profileError) {
				await serviceClient.auth.admin.deleteUser(invited.user.id);
				throw profileError;
			}
			return json({ message: 'Convite enviado com sucesso.' });
		}
		if (payload.action === 'create') {
			const email = payload.email?.trim().toLowerCase();
			if (!email || !email.includes('@')) return json({ error: 'Informe um e-mail válido.' }, 400);
			if (!payload.password || !isStrongPassword(payload.password)) return json({ error: passwordRequirement }, 400);
			const { data: created, error: createError } = await serviceClient.auth.admin.createUser({
				email,
				password: payload.password,
				email_confirm: true,
				user_metadata: { must_change_password: Boolean(payload.mustChangePassword) },
			});
			if (createError) throw createError;
			const { error: profileError } = await serviceClient.from('perfis_admin').upsert({ user_id: created.user.id, ativo: true, administrador_principal: false });
			if (profileError) {
				await serviceClient.auth.admin.deleteUser(created.user.id);
				throw profileError;
			}
			return json({ message: 'Usuário criado com sucesso.' });
		}

		if (!payload.userId || payload.userId === userData.user.id) return json({ error: 'Usuário inválido ou protegido.' }, 400);
		const { data: targetProfile, error: targetError } = await serviceClient
			.from('perfis_admin')
			.select('administrador_principal')
			.eq('user_id', payload.userId)
			.maybeSingle();
		if (targetError) throw targetError;
		if (!targetProfile || targetProfile.administrador_principal) return json({ error: 'Este usuário está protegido.' }, 403);
		if (payload.action === 'reset-password') {
			if (!payload.password || !isStrongPassword(payload.password)) return json({ error: passwordRequirement }, 400);
			const { data: targetUser, error: targetUserError } = await serviceClient.auth.admin.getUserById(payload.userId);
			if (targetUserError) throw targetUserError;
			const { error } = await serviceClient.auth.admin.updateUserById(payload.userId, {
				password: payload.password,
				user_metadata: {
					...(targetUser.user.user_metadata ?? {}),
					must_change_password: Boolean(payload.mustChangePassword),
				},
			});
			if (error) throw error;
			return json({ message: 'Senha redefinida com sucesso.' });
		}
		if (payload.action === 'deactivate') {
			const { error } = await serviceClient.from('perfis_admin').update({ ativo: false }).eq('user_id', payload.userId);
			if (error) throw error;
			return json({ message: 'Acesso desativado com sucesso.' });
		}
		if (payload.action === 'activate') {
			const { error } = await serviceClient.from('perfis_admin').update({ ativo: true }).eq('user_id', payload.userId);
			if (error) throw error;
			return json({ message: 'Acesso reativado com sucesso.' });
		}
		if (payload.action === 'delete') {
			const { error: deactivateError } = await serviceClient
				.from('perfis_admin')
				.update({ ativo: false })
				.eq('user_id', payload.userId);
			if (deactivateError) throw deactivateError;
			const { error } = await serviceClient.auth.admin.deleteUser(payload.userId);
			if (error) throw error;
			return json({ message: 'Usuário excluído definitivamente.' });
		}

		return json({ error: 'Ação inválida.' }, 400);
	} catch (error) {
		return json({ error: errorMessage(error) }, 500);
	}
});
