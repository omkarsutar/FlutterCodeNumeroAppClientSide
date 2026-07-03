const RAZORPAY_KEY_ID = Deno.env.get('RAZORPAY_KEY_ID') || '';
const RAZORPAY_KEY_SECRET = Deno.env.get('RAZORPAY_KEY_SECRET') || '';

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders() });
  }

  try {
    const {
      amountPaise,
      currency = 'INR',
      receipt,
      userId,
      poIds = [],
      notes = {},
    } = await req.json();

    if (!RAZORPAY_KEY_ID || !RAZORPAY_KEY_SECRET) {
      throw new Error('Razorpay credentials are not configured.');
    }

    if (!amountPaise || amountPaise <= 0 || !userId) {
      return new Response(
        JSON.stringify({ error: 'Missing required details. amountPaise and userId are required.' }),
        {
          status: 400,
          headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        },
      );
    }

    const authHeader = 'Basic ' + btoa(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`);
    const response = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        Authorization: authHeader,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: Math.round(amountPaise),
        currency,
        receipt: receipt || `receipt_${Date.now()}`,
        notes: {
          user_id: userId,
          po_ids: Array.isArray(poIds) ? JSON.stringify(poIds) : '[]',
          ...notes,
        },
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      return new Response(
        JSON.stringify({
          error: data?.error?.description ?? data?.error?.reason ?? 'Failed to create Razorpay order.',
          raw: data,
        }),
        {
          status: response.status,
          headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        },
      );
    }

    return new Response(
      JSON.stringify({
        orderId: data.id,
        amount: data.amount,
        currency: data.currency,
      }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
      },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
      },
    );
  }
});
