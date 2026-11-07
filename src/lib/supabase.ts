import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
	throw new Error(
		'Configuração do Supabase ausente: defina PUBLIC_SUPABASE_URL e PUBLIC_SUPABASE_ANON_KEY.',
	);
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
