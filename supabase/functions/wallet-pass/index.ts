import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function escapeVcard(value: string): string {
  return value
    .replace(/\\/g, "\\\\")
    .replace(/;/g, "\\;")
    .replace(/,/g, "\\,")
    .replace(/\n/g, "\\n");
}

function buildVcard(profile: Record<string, string | null>): string {
  const lines = [
    "BEGIN:VCARD",
    "VERSION:3.0",
    `FN:${escapeVcard(profile.display_name ?? "GiroCall User")}`,
  ];

  if (profile.title) lines.push(`TITLE:${escapeVcard(profile.title)}`);
  if (profile.company) lines.push(`ORG:${escapeVcard(profile.company)}`);
  if (profile.phone) lines.push(`TEL;TYPE=CELL:${escapeVcard(profile.phone)}`);
  if (profile.email) lines.push(`EMAIL;TYPE=INTERNET:${escapeVcard(profile.email)}`);
  if (profile.website) lines.push(`URL:${escapeVcard(profile.website)}`);

  const address = [
    profile.address_line1,
    profile.city,
    profile.state,
    profile.postal_code,
    profile.country,
  ]
    .filter(Boolean)
    .join(", ");

  if (address) {
    lines.push(
      `ADR;TYPE=WORK:;;${escapeVcard(profile.address_line1 ?? "")};${escapeVcard(profile.city ?? "")};${escapeVcard(profile.state ?? "")};${escapeVcard(profile.postal_code ?? "")};${escapeVcard(profile.country ?? "")}`,
    );
  }

  if (profile.bio) lines.push(`NOTE:${escapeVcard(profile.bio)}`);

  lines.push("END:VCARD");
  return lines.join("\r\n");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const slug = url.searchParams.get("slug");
    const platform = url.searchParams.get("platform") ?? "vcard";

    if (!slug) {
      return new Response(JSON.stringify({ error: "slug is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    const { data: profile, error } = await supabase
      .from("user_profiles")
      .select("*")
      .eq("slug", slug)
      .eq("is_public", true)
      .maybeSingle();

    if (error) throw error;
    if (!profile) {
      return new Response(JSON.stringify({ error: "Profile not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const vcard = buildVcard(profile);

    if (platform === "apple" || platform === "google") {
      const configured =
        platform === "apple"
          ? Deno.env.get("APPLE_PASS_TYPE_ID")
          : Deno.env.get("GOOGLE_WALLET_ISSUER_ID");

      if (!configured) {
        return new Response(
          JSON.stringify({
            message:
              `${platform === "apple" ? "Apple Wallet" : "Google Wallet"} is not configured yet. Download the vCard instead.`,
            fallback: "vcard",
            vcard,
          }),
          {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }

      // Wallet signing requires platform certificates — extend here when configured.
      return new Response(
        JSON.stringify({
          message: "Wallet pass generation pending certificate setup.",
          platform,
          slug,
        }),
        {
          status: 501,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    return new Response(vcard, {
      status: 200,
      headers: {
        ...corsHeaders,
        "Content-Type": "text/vcard; charset=utf-8",
        "Content-Disposition": `attachment; filename="${slug}.vcf"`,
      },
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : "Unknown error";
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});