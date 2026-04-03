/* import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const RAZORPAY_KEY_SECRET = Deno.env.get('RAZORPAY_KEY_SECRET') || '';

Deno.serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    });
  }

  try {
    const { razorpay_payment_id, razorpay_order_id, razorpay_signature, poIds, userId } = await req.json();

    // Basic validation
    if (!razorpay_payment_id || !poIds || !userId) {
      return new Response(JSON.stringify({ error: "Missing required details. Ensure payment_id, poIds, and userId are sent." }), {
        status: 400,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
      });
    }

    // --- 1. Verify Signature (Only if Order ID and Signature are provided) ---
    // If you want FULL security, you must create a Razorpay Order first and pass its ID to the app.
    if (razorpay_order_id && razorpay_signature) {
      const textData = razorpay_order_id + "|" + razorpay_payment_id;
      const encoder = new TextEncoder();
      const keyData = encoder.encode(RAZORPAY_KEY_SECRET);
      const msgData = encoder.encode(textData);

      const key = await crypto.subtle.importKey(
        "raw",
        keyData,
        { name: "HMAC", hash: "SHA-256" },
        false,
        ["sign"]
      );

      const signatureBuffer = await crypto.subtle.sign("HMAC", key, msgData);
      const signatureArray = Array.from(new Uint8Array(signatureBuffer));
      const generated_signature = signatureArray.map((b) => b.toString(16).padStart(2, "0")).join("");

      if (generated_signature !== razorpay_signature) {
        return new Response(JSON.stringify({ error: 'Invalid signature. Security check failed.' }), {
          status: 400,
          headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        });
      }
    } else {
      console.log("Proceeding without signature verification (Simple Mode)");
    }

    // --- 2. Update Database ---
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Create the main purchase order
    const { data: poData, error: poError } = await supabase
      .from('purchase_order')
      .insert({
        'status': 'confirmed',
        'birthdate_ids': poIds,
        'created_by': userId,
        'updated_by': userId,
        'user_comment': 'Birthdate Analysis Order',
        'po_line_item_count': poIds.length,
        'payment_id': razorpay_payment_id,
      })
      .select('po_id')
      .single();

    if (poError) throw poError;

    const generatedPoId = poData.po_id;

    // Update status and po_id for all selected birthdate records
    for (const id of poIds) {
      const { error: bError } = await supabase
        .from('birthdates')
        .update({ 'status': 'confirmed', 'po_id': generatedPoId })
        .eq('id', id);

      if (bError) throw bError;
    }

    return new Response(JSON.stringify({ poId: generatedPoId }), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });
  }
}); */