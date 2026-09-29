import "jsr:@supabase/functions-js/edge-runtime.d.ts";

export interface MakyPayWebhookPayload {
  // TODO(MakyPay docs): provider event shape
  event_id: string;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const _secret = Deno.env.get("MAKYPAY_WEBHOOK_SECRET");
  const _raw = await req.text();

  // TODO(MakyPay docs): verify signature with _secret.
  // TODO: idempotent update of payments + entitlements (service role).

  return new Response("ok", { status: 200 });
});
