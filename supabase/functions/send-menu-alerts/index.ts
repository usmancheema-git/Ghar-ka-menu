// @ts-nocheck Supabase Edge Functions are type-checked by the Deno runtime.

declare const Deno: {
  env: { get(name: string): string | undefined };
  serve(handler: (request: Request) => Response | Promise<Response>): void;
};

// Supabase Edge Functions resolve this URL import through Deno's module loader.
// @ts-ignore TypeScript's standard server does not resolve Deno URL imports.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

interface PlanRow {
  household_id: string;
  dishes?: { name?: string } | null;
}

interface HouseholdRow {
  id: string;
  name: string;
}

interface MemberRow {
  fcm_token?: string | null;
}

// @ts-ignore Deno is provided by the Supabase Edge runtime.
const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
// @ts-ignore Deno is provided by the Supabase Edge runtime.
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
// @ts-ignore Deno is provided by the Supabase Edge runtime.
const fcmServerKey = Deno.env.get('FCM_SERVER_KEY') ?? '';

// @ts-ignore Deno is provided by the Supabase Edge runtime.
Deno.serve(async () => {
  if (!supabaseUrl || !serviceRoleKey || !fcmServerKey) {
    return new Response('Missing notification secrets', { status: 500 });
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);
  const tomorrow = new Date();
  tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);
  const date = tomorrow.toISOString().slice(0, 10);
  const currentTime = new Date().toISOString().slice(11, 19);

  const { data: households, error: householdsError } = await supabase
    .from('households')
    .select('id, name')
    .eq('alert_time', currentTime);

  if (householdsError) {
    return Response.json({ error: householdsError.message }, { status: 500 });
  }

  let sent = 0;
  for (const household of (households ?? []) as HouseholdRow[]) {
    const { data: plan } = (await supabase
      .from('day_plans')
      .select('household_id, dishes(name)')
      .eq('household_id', household.id)
      .eq('date', date)
      .maybeSingle());

    const { data: members } = (await supabase
      .from('members')
      .select('fcm_token')
      .eq('household_id', household.id)
      .not('fcm_token', 'is', null)) as { data: MemberRow[] | null };

    const dishName = (plan as PlanRow | null)?.dishes?.name;
    const memberRows = (members ?? []) as MemberRow[];
    const tokens = memberRows
      .map((member: MemberRow) => member.fcm_token)
      .filter((token: string | null | undefined): token is string => Boolean(token));

    if (tokens.length === 0) continue;

    const response = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `key=${fcmServerKey}`,
      },
      body: JSON.stringify({
        registration_ids: tokens,
        notification: {
          title: household.name,
          body: dishName
            ? `Tomorrow's lunch: ${dishName}`
            : 'No lunch is planned for tomorrow.',
        },
        data: { household_id: household.id, date },
      }),
    });

    if (response.ok) sent += tokens.length;
  }

  return Response.json({ date, currentTime, sent });
});
