import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { encode as base64Encode } from "https://deno.land/std@0.168.0/encoding/base64.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight routing rules cleanly
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Verify and Extract Authorization headers from incoming Flutter payload
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing Authorization header" }), { 
        status: 401, 
        headers: corsHeaders 
      })
    }

    const token = authHeader.replace('Bearer ', '')

    // 2. Initialize the Supabase Client with isolated memory context
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { 
        global: { headers: { Authorization: authHeader } },
        auth: {
          persistSession: false,
          autoRefreshToken: false
        }
      }
    )

    // 3. Extract input payload and validate session context state
    const { birthdate_id } = await req.json()
    if (!birthdate_id) throw new Error("Missing birthdate_id parameter.")

    // Fetch user via token parameter
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(token)
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized user session" }), { 
        status: 401, 
        headers: corsHeaders 
      })
    }

    // 4. Validate access using your system schema RPC function routines
    const { data: hasAccess, error: accessError } = await supabaseClient.rpc(
      'validate_birthdate_access', 
      { birthdate_id: birthdate_id, check_po_id: true }
    )
    if (accessError || !hasAccess) {
      return new Response(JSON.stringify({ error: "Unauthorized or No Active Purchase Found" }), { 
        status: 403, 
        headers: corsHeaders 
      })
    }

    // 5. Fetch User's chosen language selection from public profiles record 
    const { data: userData } = await supabaseClient
      .from('users')
      .select('user_language')
      .eq('user_id', user.id)
      .single()

    const lang = userData?.user_language || 'hi' // fallback default string

    // 6. Gather all relevant numerology report data fields concurrently
    const [personality, luckyValues, remedies, shareAdvice] = await Promise.all([
      supabaseClient.rpc('get_personality_data', { birthdate_id }),
      supabaseClient.rpc('get_lucky_unlucky_values', { birthdate_id }),
      supabaseClient.rpc('get_remedies_for_birthdate', { birthdate_id }),
      supabaseClient.rpc('get_share_market_advice', { birthdate_id })
    ])

    // 7. Safely unwrap data packets
    const pData = personality.data?.[0] || {}
    const sAdvice = shareAdvice.data?.[0] || {}
    
    let title = "Numerology Analysis Report"
    let lord = pData.lord || ''
    let description = pData.description || ''
    let qualities = pData.qualities || ''
    let marketAdvice = sAdvice.description_en || ''

    if (lang === 'hi') {
      title = "अंकज्योतिष विश्लेषण रिपोर्ट"
      lord = pData.lord_hindi || lord
      description = pData.description_hindi || description
      qualities = pData.qualities_hindi || qualities
      marketAdvice = sAdvice.description_hi || marketAdvice
    } else if (lang === 'mr') {
      title = "संख्याशास्त्र विश्लेषण अहवाल"
      lord = pData.lord_marathi || lord
      description = pData.description_marathi || description
      qualities = pData.qualities_marathi || qualities
      marketAdvice = sAdvice.description_mr || marketAdvice
    }

    // 8. Compose raw HTML template sheet (Injecting correct Noto Sans Devanagari links)
    const htmlContent = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>${title}</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Devanagari:wght@400;700&display=swap" rel="stylesheet">
        <style>
          body {
            font-family: 'Noto Sans Devanagari', Arial, sans-serif;
            padding: 40px;
            color: #2D3748;
            line-height: 1.8;
            font-size: 14px;
          }
          h1 { color: #4C51BF; text-align: center; border-bottom: 2px solid #4C51BF; padding-bottom: 12px; margin-bottom: 30px; }
          h2 { color: #2B6CB0; margin-top: 25px; font-size: 1.4em; border-bottom: 1px dashed #CBD5E0; padding-bottom: 5px; }
          p { margin-bottom: 15px; text-align: justify; }
          .section { background: #F7FAFC; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 5px solid #4C51BF; }
        </style>
      </head>
      <body>
        <h1>${title}</h1>
        
        <div class="section">
          <h2>स्वामी ग्रह (Lord): ${lord}</h2>
          <p>${description}</p>
        </div>

        <div class="section">
          <h2>गुण (Qualities)</h2>
          <p>${qualities}</p>
        </div>

        <div class="section">
          <h2>शेअर बाजार सल्ला (Stock Market Advice)</h2>
          <p>${marketAdvice}</p>
        </div>
      </body>
      </html>
    `

    // 9. Fetch API key from Supabase Environment Secrets
    const apiKey = Deno.env.get('HTML2PDF_API_KEY')
    if (!apiKey) {
      return new Response(JSON.stringify({ error: "Missing HTML2PDF_API_KEY environment variable. Please set it in your Supabase dashboard." }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Convert HTML using HTML2PDF Cloud API (Chromium backend handles shaping)
    const pdfApiResponse = await fetch('https://api.html2pdf.app/v1/generate', {
      method: 'POST',
      headers: { 
        'Content-Type': 'application/json',
        'X-API-Key': apiKey
      },
      body: JSON.stringify({
        html: htmlContent,
        options: { 
          format: 'A4', 
          margin: { top: '20mm', bottom: '20mm', left: '15mm', right: '15mm' } 
        }
      })
    })

    if (!pdfApiResponse.ok) {
      const errorText = await pdfApiResponse.text()
      throw new Error(`PDF rendering service failed: ${errorText}`)
    }

    const pdfBuffer = await pdfApiResponse.arrayBuffer()
    const base64Pdf = base64Encode(new Uint8Array(pdfBuffer))

    // 10. Return the base64 string back to Flutter
    return new Response(base64Pdf, {
      status: 200,
      headers: {
        ...corsHeaders,
        'Content-Type': 'text/plain',
      }
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
