// Supabase Edge Function: delete-user-account
//
// Deletes a user's Supabase Auth account. This needs the service-role key,
// so it has to run server-side here rather than in the browser.
//
// Only admins can call this. The caller's access token is checked against
// the profiles table before anything is deleted.
//
// Deploy with: supabase functions deploy delete-user-account

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
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return jsonResponse({ error: 'Missing authorization header' });
    }

    const { userId } = await req.json();
    if (!userId) {
      return jsonResponse({ error: 'Missing userId' });
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Check the caller's token belongs to a logged-in admin.
    const token = authHeader.replace('Bearer ', '');
    const { data: { user: caller }, error: callerError } = await supabaseAdmin.auth.getUser(token);
    if (callerError || !caller) {
      return jsonResponse({ error: 'Invalid session' });
    }

    const { data: callerProfile } = await supabaseAdmin
      .from('profiles')
      .select('role')
      .eq('id', caller.id)
      .single();

    if (callerProfile?.role !== 'admin') {
      return jsonResponse({ error: 'Only admins can delete accounts' });
    }

    // Deletes the profile row. Related tables (specialist_profiles,
    // volunteer_profiles, subscriptions, next_of_kin_profiles, etc.) cascade
    // automatically via foreign keys.
    const { error: profileError } = await supabaseAdmin.from('profiles').delete().eq('id', userId);
    if (profileError) {
      return jsonResponse({ error: profileError.message });
    }

    // Deletes the actual login account.
    const { error: authDeleteError } = await supabaseAdmin.auth.admin.deleteUser(userId);
    // "User not found" just means it's already gone — treat as success.
    if (authDeleteError && !/not.?found/i.test(authDeleteError.message || '')) {
      return jsonResponse({ error: authDeleteError.message });
    }

    return jsonResponse({ success: true });
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
