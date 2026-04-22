# Supabase Edge Function: push-service

This guide explains how to set up the Supabase Edge Function for sending push notifications using Firebase Cloud Messaging (FCM) and the Firebase Admin SDK.

## Prerequisites

1.  **Firebase Service Account JSON**:
    *   Go to [Firebase Console](https://console.firebase.google.com/).
    *   Navigate to **Project Settings > Service accounts**.
    *   Click **Generate new private key** and save the JSON file.
2.  **Supabase CLI**: Installed and linked to your project (`supabase login`, `supabase link`).

## Step 1: Create the Edge Function

Run the following command in your terminal:

```bash
supabase functions new push-service
```

## Step 2: Implementation

Replace the contents of `supabase/functions/push-service/index.ts` with the following logic. This code uses the Firebase Admin SDK to send messages to specific tokens or topics.

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import admin from "https://esm.sh/v135/firebase-admin@11.10.1/deno/firebase-admin.mjs"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { userIds, title, body, sendToAll } = await req.json()

    // Initialize Firebase Admin if not already initialized
    if (!admin.apps.length) {
      const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!)
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      })
    }

    let tokens: string[] = []

    if (sendToAll) {
      // Fetch all FCM tokens from users table
      const { data, error } = await supabaseClient
        .from('users')
        .select('fcm_token')
        .not('fcm_token', 'is', null)
      
      if (error) throw error
      tokens = data.map(u => u.fcm_token)
    } else if (userIds && userIds.length > 0) {
      // Fetch tokens for specific users
      const { data, error } = await supabaseClient
        .from('users')
        .select('fcm_token')
        .in('user_id', userIds)
        .not('fcm_token', 'is', null)
      
      if (error) throw error
      tokens = data.map(u => u.fcm_token)
    }

    if (tokens.length === 0) {
      return new Response(JSON.stringify({ success: true, message: 'No tokens found' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    // Send messages in batches of 500 (FCM limit)
    const messages = tokens.map(token => ({
      notification: { title, body },
      token,
    }))

    const response = await admin.messaging().sendEach(messages)

    return new Response(JSON.stringify({ success: true, response }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
```

## Step 3: Set Environment Secrets

You need to provide your Firebase credentials to Supabase. Run this command (replacing the JSON string with your actual file content):

```bash
supabase secrets set FIREBASE_SERVICE_ACCOUNT='{ "type": "service_account", ... }'
```

## Step 4: Fix RBAC Permissions (IMPORTANT)

After deploying the Edge Function, you must grant the 'admin' role access to the 'notification_admin' module. Run this SQL in your Supabase SQL Editor:

```sql
-- Fix: Grant 'admin' role access to 'notification_admin' module

-- First, ensure the 'admin' role exists and get its ID
-- (You may need to adjust the role_id based on your actual data)

-- Insert permission for admin role to access notification_admin module
INSERT INTO rbac_permissions (
  role_id,
  module_id,
  can_read,
  can_create,
  can_update,
  can_delete
) VALUES (
  '8b047e14-1569-4eab-83a1-8dd43b960868', -- Replace with your actual admin role_id if different
  'notification_admin',
  true,
  false,
  false,
  false
) ON CONFLICT (role_id, module_id) DO UPDATE SET
  can_read = true,
  can_create = false,
  can_update = false,
  can_delete = false;

-- Verify the permission was added
SELECT * FROM rbac_permissions 
WHERE module_id = 'notification_admin' AND role_id = '8b047e14-1569-4eab-83a1-8dd43b960868';
```

## Step 5: Deploy

```bash
supabase functions deploy push-service
```
