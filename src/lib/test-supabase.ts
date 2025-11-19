import { supabase } from './supabase'

/**
 * Test Supabase connection
 * Run this to verify that your Supabase configuration is working
 */
export async function testSupabaseConnection() {
  try {
    console.log('Testing Supabase connection...')
    console.log('URL:', import.meta.env.VITE_SUPABASE_URL)

    // Try to get the current session (will be null if not logged in, but connection works)
    const { data, error } = await supabase.auth.getSession()

    if (error) {
      console.error('❌ Supabase connection error:', error.message)
      return false
    }

    console.log('✅ Supabase connection successful!')
    console.log('Session:', data.session ? 'Active' : 'No active session (this is normal)')
    return true
  } catch (error) {
    console.error('❌ Unexpected error:', error)
    return false
  }
}

// You can call this function from your App.tsx or main.tsx to test
// testSupabaseConnection()
