import "jsr:@supabase/functions-js/edge-runtime.d.ts";

export interface MakyPayCheckoutRequest {
  plan_id: string;
}

export interface MakyPayCheckoutResponse {
  checkout_url: string;
  reference: string;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const _apiKey = Deno.env.get("MAKYPAY_API_KEY");
  const body = (await req.json()) as MakyPayCheckoutRequest;

  // TODO(MakyPay docs): authenticate and create checkout session for body.plan_id.
  const _response: MakyPayCheckoutResponse = {
    checkout_url: "",
    reference: "",
  };

  return Response.json(_response, { status: 501 });
});
