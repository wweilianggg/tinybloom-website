// Supabase Edge Function: delete-user-account
//
// Permanently deletes a user's Supabase Auth account (auth.users). The anon
// key used by admin/users.html and admin/applications.html can delete the
// `profiles` row (and, via FK cascade, related app tables) but can NEVER
// delete the underlying auth.users row — that requires the Admin API, which
// needs the service-role key and therefore must run server-side, here.
//
// This was the root cause of "deleted" accounts not being reusable: after a
// client-side delete, the profiles row was gone but auth.users still held
// the email, so Supabase Auth still considered that address registered and
// blocked re-registration (or worse, let someone sign up with no way to
// recreate a matching profile). Deleting the Auth account here is what
// actually frees the email for a clean re-registration.
//
// The caller's own access token is required (not just the anon key) so this
// endpoint can verify they're an admin before doing anything destructive.
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
      return jsonResponse({ error: 'Missing authorization header' }, 401);
    }

    const { userId } = await req.json();
    if (!userId) {
      return jsonResponse({ error: 'Missing userId' }, 400);
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Verify the caller's token is valid, then check they're actually an admin.
    const token = authHeader.replace('Bearer ', '');
    const { data: { user: caller }, error: callerError } = await supabaseAdmin.auth.getUser(token);
    if (callerError || !caller) {
      return jsonResponse({ error: 'Invalid session' }, 401);
    }

    const { data: callerProfile } = await supabaseAdmin
      .from('profiles')
      .select('role')
      .eq('id', caller.id)
      .single();

    if (callerProfile?.role !== 'admin') {
      return jsonResponse({ error: 'Only admins can delete accounts' }, 403);
    }

    // Same as the existing client-side delete: removes the profile row,
    // which cascades to specialist_profiles/volunteer_profiles/subscriptions/
    // next_of_kin_profiles etc. via foreign keys. Not fatal if it's already
    // gone (e.g. retrying after a partial failure).
    const { error: profileError } = await supabaseAdmin.from('profiles').delete().eq('id', userId);
    if (profileError) {
      return jsonResponse({ error: profileError.message }, 400);
    }

    // The step the anon key could never do — actually frees the email.
    const { error: authDeleteError } = await supabaseAdmin.auth.admin.deleteUser(userId);
    if (authDeleteError) {
      return jsonResponse({ error: authDeleteError.message }, 400);
    }

    return jsonResponse({ success: true });
  } catch (err) {
    return jsonResponse({ error: err instanceof Error ? err.message : 'Unexpected error' }, 500);
  }
});

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status,
  });
}
