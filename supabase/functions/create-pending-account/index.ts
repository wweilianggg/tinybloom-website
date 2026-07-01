// Supabase Edge Function: create-pending-account
//
// Creates a specialist/volunteer auth account WITHOUT Supabase's automatic
// "confirm your email" send. This requires the service-role key, which is
// only available server-side here (Edge Functions get SUPABASE_URL and
// SUPABASE_SERVICE_ROLE_KEY injected automatically at runtime) — it must
// never be shipped to the browser.
//
// The confirmation email is deliberately NOT sent at this point. Admin
// approval (admin/specialists.html, admin/volunteers.html) later calls
// supabase.auth.resend({ type: 'signup', email }) with the anon key to
// trigger it once the application is approved (and again on any later
// re-approval).
//
// Deploy with: supabase functions deploy create-pending-account

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { email, password, userData } = await req.json();

    if (!email || !password || !userData?.role) {
      return jsonResponse({ error: 'Missing email, password, or userData.role' });
    }

    if (userData.role !== 'specialist' && userData.role !== 'volunteer') {
      return jsonResponse({ error: 'This endpoint only supports specialist/volunteer signups' });
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: false,
      user_metadata: userData,
    });

    if (error) {
      return jsonResponse({ error: error.message });
    }

    return jsonResponse({ user: data.user });
  } catch (err) {
    return jsonResponse({ error: err instanceof Error ? err.message : 'Unexpected error' });
  }
});

function jsonResponse(body: unknown) {
  return new Response(JSON.stringify(body), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status: 200,
  });
}
