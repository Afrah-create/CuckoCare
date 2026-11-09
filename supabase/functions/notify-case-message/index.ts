import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const GENERIC_BODY = "New message on your vet request";

function buildFcmMessage(token: string, requestId: string, locale: string) {
  return {
    message: {
      token,
      notification: {
        title: "CucoCare",
        body: locale === "lg" ? GENERIC_BODY : GENERIC_BODY,
      },
      data: {
        type: "case_message",
        request_id: requestId,
      },
      android: {
        priority: "HIGH",
        collapse_key: `case_${requestId}`,
        ttl: "86400s",
        notification: {
          channel_id: "case_messages",
          tag: `case_${requestId}`,
        },
      },
    },
  };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const payload = await req.json();
  const requestId = payload.request_id as string | undefined;
  const messageId = payload.message_id as string | undefined;
  if (!requestId || !messageId) {
    return Response.json({ error: "missing_ids" }, { status: 400 });
  }

  // Service account and FCM HTTP v1 are configured via secrets. No message text.
  const _sa = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  if (!_sa) {
    return Response.json({ skipped: true, reason: "push_unavailable" });
  }

  return Response.json({
    ok: true,
    preview: buildFcmMessage("token", requestId, "en"),
  });
});
