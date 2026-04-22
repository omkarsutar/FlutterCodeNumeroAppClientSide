/* import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import admin from "https://esm.sh/v135/firebase-admin@11.10.1/deno/firebase-admin.mjs"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Initialize Supabase Client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 2. Parse Request Body
    const { userIds, title, body, sendToAll } = await req.json()
    console.log('Request received:', { userIds, title, body, sendToAll })

    // 3. Initialize Firebase Admin
    if (!admin.apps.length) {
      const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
      if (!serviceAccountStr) {
        throw new Error('FIREBASE_SERVICE_ACCOUNT secret is not set')
      }

      try {
        const serviceAccount = JSON.parse(serviceAccountStr)
        console.log('Service Account Project ID:', serviceAccount.project_id)

        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
          projectId: serviceAccount.project_id, // Explicitly set project ID
        })
        console.log('Firebase Admin initialized successfully with project ID:', serviceAccount.project_id)
      } catch (parseErr) {
        const error = parseErr as Error;
        console.error('Error parsing FIREBASE_SERVICE_ACCOUNT:', error)
        throw new Error(`Invalid FIREBASE_SERVICE_ACCOUNT JSON format: ${error.message}`)
      }
    }

    // 4. Fetch FCM Tokens
    let tokens: string[] = []

    if (sendToAll) {
      console.log('Fetching all tokens...')
      const { data, error } = await supabaseClient
        .from('users')
        .select('fcm_token')
        .not('fcm_token', 'is', null)

      if (error) throw error
      tokens = data.map(u => u.fcm_token)
    } else if (userIds && userIds.length > 0) {
      console.log(`Fetching tokens for userIds: ${userIds}`)
      const { data, error } = await supabaseClient
        .from('users')
        .select('fcm_token')
        .in('user_id', userIds)
        .not('fcm_token', 'is', null)

      if (error) throw error
      tokens = data.map(u => u.fcm_token)
    }

    console.log(`Found ${tokens.length} valid tokens`)

    if (tokens.length === 0) {
      return new Response(JSON.stringify({
        success: true,
        message: 'No tokens found to send notifications to.'
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    // 5. Send Notifications
    const messages = tokens.map(token => ({
      notification: { title, body },
      token,
    }))

    // Use sendEach for batch delivery
    const response = await admin.messaging().sendEach(messages)
    console.log('Notifications sent successfully:', response)

    return new Response(JSON.stringify({
      success: true,
      sentCount: response.successCount,
      failureCount: response.failureCount,
      results: response.responses
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error('Function error:', error)
    return new Response(JSON.stringify({
      error: error.message,
      stack: error.stack
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
 */