import { createClient } from "npm:@supabase/supabase-js@2";
import nodemailer from "npm:nodemailer@6.9.16";

const PURPOSE_SIGNUP = "signup";
const PURPOSE_RESET = "password_reset";
const CODE_TTL_MS = 10 * 60 * 1000;
const RESEND_MS = 60 * 1000;
const MAX_SENDS_PER_HOUR = 5;
const MAX_ATTEMPTS = 5;

type Purpose = typeof PURPOSE_SIGNUP | typeof PURPOSE_RESET;

interface Body {
  action?: string;
  email?: string;
  purpose?: string;
  code?: string;
  password?: string;
  new_password?: string;
  app_role?: string;
  display_name?: string;
}

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: cors });
  }
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  let body: Body;
  try {
    body = (await req.json()) as Body;
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const email = normalizeEmail(body.email);
  const purpose = body.purpose as Purpose;
  if (!email || !email.includes("@")) {
    return json({ error: "invalid_email" }, 400);
  }
  if (purpose !== PURPOSE_SIGNUP && purpose !== PURPOSE_RESET) {
    return json({ error: "invalid_purpose" }, 400);
  }

  const admin = createClient(
    mustEnv("SUPABASE_URL"),
    mustEnv("SUPABASE_SERVICE_ROLE_KEY"),
    { auth: { persistSession: false, autoRefreshToken: false } },
  );

  try {
    if (body.action === "send") {
      return await handleSend(admin, email, purpose, body);
    }
    if (body.action === "verify") {
      return await handleVerify(admin, email, purpose, body);
    }
    return json({ error: "invalid_action" }, 400);
  } catch (err) {
    console.error("email-otp failed", err);
    return json({ error: "server_error" }, 500);
  }
});

async function handleSend(
  admin: ReturnType<typeof createClient>,
  email: string,
  purpose: Purpose,
  body: Body,
): Promise<Response> {
  const recent = await admin
    .from("email_otp_challenges")
    .select("id, created_at")
    .eq("email", email)
    .eq("purpose", purpose)
    .gte("created_at", new Date(Date.now() - 60 * 60 * 1000).toISOString())
    .order("created_at", { ascending: false });

  if ((recent.data?.length ?? 0) >= MAX_SENDS_PER_HOUR) {
    return json({ error: "rate_limited" }, 429);
  }
  const last = recent.data?.[0]?.created_at;
  if (last && Date.now() - new Date(last).getTime() < RESEND_MS) {
    return json({ error: "resend_wait" }, 429);
  }

  const user = await findUserByEmail(email);

  if (purpose === PURPOSE_SIGNUP) {
    const password = body.password ?? "";
    if (password.length < 8) {
      return json({ error: "weak_password" }, 400);
    }
    if (user?.email_confirmed_at) {
      return json({ error: "already_registered" }, 400);
    }
    if (!user) {
      const role = body.app_role === "vet" ? "vet" : "farmer";
      const displayName = (body.display_name ?? "").trim();
      const created = await admin.auth.admin.createUser({
        email,
        password,
        email_confirm: false,
        user_metadata: {
          app_role: role,
          ...(displayName ? { display_name: displayName } : {}),
        },
      });
      if (created.error) {
        const msg = created.error.message.toLowerCase();
        if (msg.includes("already")) {
          return json({ error: "already_registered" }, 400);
        }
        console.error("createUser", created.error);
        return json({ error: "server_error" }, 500);
      }
    }
  } else if (!user) {
    return json({ ok: true });
  }

  const code = randomSixDigits();
  const codeHash = await hashCode(email, purpose, code);
  const expiresAt = new Date(Date.now() + CODE_TTL_MS).toISOString();

  await admin
    .from("email_otp_challenges")
    .update({ consumed_at: new Date().toISOString() })
    .eq("email", email)
    .eq("purpose", purpose)
    .is("consumed_at", null);

  const inserted = await admin.from("email_otp_challenges").insert({
    email,
    purpose,
    code_hash: codeHash,
    expires_at: expiresAt,
  });
  if (inserted.error) {
    console.error("insert challenge", inserted.error);
    return json({ error: "server_error" }, 500);
  }

  await sendMail({
    to: email,
    purpose,
    code,
  });

  return json({ ok: true });
}

async function handleVerify(
  admin: ReturnType<typeof createClient>,
  email: string,
  purpose: Purpose,
  body: Body,
): Promise<Response> {
  const code = (body.code ?? "").trim();
  if (!/^\d{6}$/.test(code)) {
    return json({ error: "invalid_code" }, 400);
  }

  const row = await admin
    .from("email_otp_challenges")
    .select("id, code_hash, expires_at, attempt_count, consumed_at")
    .eq("email", email)
    .eq("purpose", purpose)
    .is("consumed_at", null)
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (row.error || !row.data) {
    return json({ error: "invalid_code" }, 400);
  }

  const challenge = row.data;
  if (new Date(challenge.expires_at).getTime() < Date.now()) {
    return json({ error: "expired" }, 400);
  }
  if ((challenge.attempt_count ?? 0) >= MAX_ATTEMPTS) {
    return json({ error: "too_many_attempts" }, 400);
  }

  const expected = await hashCode(email, purpose, code);
  if (expected !== challenge.code_hash) {
    await admin
      .from("email_otp_challenges")
      .update({ attempt_count: (challenge.attempt_count ?? 0) + 1 })
      .eq("id", challenge.id);
    return json({ error: "invalid_code" }, 400);
  }

  const user = await findUserByEmail(email);
  if (!user) {
    return json({ error: "invalid_code" }, 400);
  }

  if (purpose === PURPOSE_RESET) {
    const password = body.new_password ?? "";
    if (password.length < 8) {
      return json({ error: "weak_password" }, 400);
    }
    const updated = await admin.auth.admin.updateUserById(user.id, {
      password,
      email_confirm: true,
    });
    if (updated.error) {
      console.error("update password", updated.error);
      return json({ error: "server_error" }, 500);
    }
  } else {
    const updated = await admin.auth.admin.updateUserById(user.id, {
      email_confirm: true,
    });
    if (updated.error) {
      console.error("confirm email", updated.error);
      return json({ error: "server_error" }, 500);
    }
  }

  await admin
    .from("email_otp_challenges")
    .update({ consumed_at: new Date().toISOString() })
    .eq("id", challenge.id);

  return json({ ok: true });
}

async function findUserByEmail(email: string) {
  const url = `${mustEnv("SUPABASE_URL")}/auth/v1/admin/users?email=${
    encodeURIComponent(email)
  }`;
  const res = await fetch(url, {
    headers: {
      Authorization: `Bearer ${mustEnv("SUPABASE_SERVICE_ROLE_KEY")}`,
      apikey: mustEnv("SUPABASE_SERVICE_ROLE_KEY"),
    },
  });
  if (!res.ok) {
    return null;
  }
  const body = await res.json();
  const users = Array.isArray(body?.users)
    ? body.users
    : Array.isArray(body)
    ? body
    : [];
  return users.find((u: { email?: string }) =>
    (u.email ?? "").toLowerCase() === email
  ) ?? null;
}

async function hashCode(email: string, purpose: string, code: string) {
  const pepper = Deno.env.get("OTP_PEPPER") ??
    mustEnv("SUPABASE_SERVICE_ROLE_KEY");
  const data = new TextEncoder().encode(
    `${pepper}:${purpose}:${email}:${code}`,
  );
  const buf = await crypto.subtle.digest("SHA-256", data);
  return [...new Uint8Array(buf)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function randomSixDigits() {
  const bytes = new Uint8Array(4);
  crypto.getRandomValues(bytes);
  const n = new DataView(bytes.buffer).getUint32(0, false) % 1_000_000;
  return n.toString().padStart(6, "0");
}

async function sendMail(opts: {
  to: string;
  purpose: Purpose;
  code: string;
}) {
  const host = Deno.env.get("SMTP_HOST") ?? "smtp.gmail.com";
  const port = Number(Deno.env.get("SMTP_PORT") ?? "587");
  const user = mustEnv("SMTP_USER");
  const pass = mustEnv("SMTP_PASSWORD");
  const fromEmail = Deno.env.get("SMTP_FROM") ?? user;
  const fromName = Deno.env.get("SMTP_FROM_NAME") ?? "CucoCare";

  const transporter = nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: { user, pass },
  });

  const isReset = opts.purpose === PURPOSE_RESET;
  const subject = isReset
    ? "Your CucoCare password reset code"
    : "Your CucoCare verification code";
  const heading = isReset ? "Reset your password" : "Verify your email";
  const intro = isReset
    ? "Use this code to choose a new password for your CucoCare account."
    : "Use this code to confirm that this email belongs to you.";

  const html = emailHtml({
    heading,
    intro,
    code: opts.code,
  });
  const text = [
    heading,
    "",
    intro,
    "",
    `Your 6-digit code: ${opts.code}`,
    `Copy this code: ${opts.code}`,
    "",
    "This code expires in 10 minutes. If you did not request it, you can ignore this email.",
    "",
    "— CucoCare",
  ].join("\n");

  await transporter.sendMail({
    from: `"${fromName}" <${fromEmail}>`,
    to: opts.to,
    subject,
    text,
    html,
  });
}

function emailHtml(opts: { heading: string; intro: string; code: string }) {
  const digits = opts.code.split("").map((d) =>
    `<td style="width:40px;height:48px;text-align:center;font-size:24px;font-weight:700;letter-spacing:0;color:#14532d;background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;font-family:ui-monospace,Menlo,Consolas,monospace;">${d}</td>`
  ).join(
    '<td style="width:8px;"></td>',
  );
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>CucoCare</title>
</head>
<body style="margin:0;padding:0;background:#f4f1ea;font-family:Georgia,'Times New Roman',serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:#f4f1ea;padding:32px 12px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:480px;background:#ffffff;border-radius:16px;overflow:hidden;border:1px solid #e7e0d4;">
          <tr>
            <td style="background:#166534;padding:24px 28px;">
              <p style="margin:0;font-size:13px;letter-spacing:0.16em;text-transform:uppercase;color:#bbf7d0;font-family:system-ui,-apple-system,sans-serif;">CucoCare</p>
              <h1 style="margin:8px 0 0;font-size:22px;line-height:1.3;color:#ffffff;">${opts.heading}</h1>
            </td>
          </tr>
          <tr>
            <td style="padding:28px;">
              <p style="margin:0 0 20px;font-size:16px;line-height:1.5;color:#3f3f46;">${opts.intro}</p>
              <table role="presentation" cellspacing="0" cellpadding="0" align="center" style="margin:0 auto 20px;">
                <tr>${digits}</tr>
              </table>
              <table role="presentation" cellspacing="0" cellpadding="0" align="center" style="margin:0 auto 12px;">
                <tr>
                  <td align="center" bgcolor="#166534" style="border-radius:10px;padding:12px 22px;-webkit-user-select:all;user-select:all;">
                    <span style="display:block;font-family:system-ui,-apple-system,sans-serif;font-size:12px;font-weight:600;letter-spacing:0.04em;text-transform:uppercase;color:#bbf7d0;">Copy code</span>
                    <span style="display:block;margin-top:4px;font-family:ui-monospace,Menlo,Consolas,monospace;font-size:22px;font-weight:700;letter-spacing:0.28em;color:#ffffff;">${opts.code}</span>
                  </td>
                </tr>
              </table>
              <p style="margin:0 0 16px;text-align:center;font-size:13px;line-height:1.5;color:#71717a;font-family:system-ui,-apple-system,sans-serif;">Long-press the code to copy it. Mail apps cannot copy with a tap.</p>
              <p style="margin:0;font-size:14px;line-height:1.5;color:#71717a;font-family:system-ui,-apple-system,sans-serif;">This code expires in <strong>10 minutes</strong>. Do not share it with anyone.</p>
            </td>
          </tr>
          <tr>
            <td style="padding:16px 28px 24px;border-top:1px solid #f4f1ea;">
              <p style="margin:0;font-size:12px;line-height:1.5;color:#a1a1aa;font-family:system-ui,-apple-system,sans-serif;">If you did not request this, you can ignore this email. Your account stays safe.</p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

function normalizeEmail(value?: string) {
  return (value ?? "").trim().toLowerCase();
}

function mustEnv(name: string) {
  const v = Deno.env.get(name);
  if (!v) {
    throw new Error(`Missing ${name}`);
  }
  return v;
}

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
