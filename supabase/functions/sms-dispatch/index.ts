import "jsr:@supabase/functions-js/edge-runtime.d.ts";

export interface MakyReachContract {
  // TODO(MakyReach docs): confirm whether a sender ID is required
  // and whether delivery webhooks are provided.
  send(input: { phone: string; message: string }): Promise<{ messageId: string }>;
}

class FakeMakyReach implements MakyReachContract {
  async send(input: { phone: string; message: string }) {
    if (!input.phone || !input.message) {
      throw new Error("invalid_sms");
    }
    return { messageId: `fake-${crypto.randomUUID()}` };
  }
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const _apiKey = Deno.env.get("MAKYREACH_API_KEY");
  const provider: MakyReachContract = new FakeMakyReach();
  const body = await req.json();
  const phone = body.phone as string | undefined;
  const message = body.message as string | undefined;
  if (!phone || !message) {
    return Response.json({ error: "missing_fields" }, { status: 400 });
  }

  const result = await provider.send({ phone, message });
  return Response.json({ provider_message_id: result.messageId, fake: true });
});
