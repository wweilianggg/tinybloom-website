// Supabase Edge Function: create-pending-account
//
// Creates a specialist/volunteer auth account without sending Supabase's
// automatic confirmation email. Uses the service-role key, so it has to run
// server-side here rather than in the browser.
//
// The confirmation email is sent later instead, when an admin approves the
// application (admin/applications.html calls supabase.auth.resend()).
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

// Always responds with HTTP 200, putting any error message in the JSON
// body's `error` field instead of the status code, since supabase-js hides
// the real error text whenever a Function returns a non-2xx status.
function jsonResponse(body: unknown) {
  return new Response(JSON.stringify(body), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status: 200,
  });
}
