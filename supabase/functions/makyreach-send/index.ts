import "jsr:@supabase/functions-js/edge-runtime.d.ts";

export interface MakyReachSendRequest {
  phone: string;
  message: string;
}

export interface MakyReachSendResponse {
  message_id: string;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const _apiKey = Deno.env.get("MAKYREACH_API_KEY");
  const body = (await req.json()) as MakyReachSendRequest;

  // TODO(MakyReach docs): send SMS with approved sender ID and rate limits.
  const _response: MakyReachSendResponse = { message_id: "" };

  return Response.json(_response, { status: 501 });
});
