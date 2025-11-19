# Supabase Setup Guide

## Option 1: Use Supabase Cloud (Recommended for Production)

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click "New Project"
4. Fill in the project details:
   - **Name**: lead-qualification-system
   - **Database Password**: Choose a strong password (save it securely)
   - **Region**: Choose the closest to your users
   - **Pricing Plan**: Start with the Free tier
5. Wait for the project to be created (takes ~2 minutes)
6. Once created, go to **Project Settings** > **API**
7. Copy the following values:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon/public key** (the `anon` key)
8. Update your `.env.local` file:
   ```env
   VITE_SUPABASE_URL=https://xxxxx.supabase.co
   VITE_SUPABASE_ANON_KEY=your_actual_anon_key_here
   ```

## Option 2: Use Supabase CLI (Local Development)

### Install Supabase CLI

**On macOS:**
```bash
brew install supabase/tap/supabase
```

**On Windows:**
```powershell
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

**On Linux:**
```bash
# Download and install
curl -fsSL https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz | tar -xz
sudo mv supabase /usr/local/bin/supabase
```

**Using npm (if the above methods don't work):**
```bash
npx supabase init
```

### Initialize Local Supabase

1. Make sure Docker is installed and running
2. Initialize Supabase in your project:
   ```bash
   npx supabase init
   ```
3. Start the local Supabase stack:
   ```bash
   npx supabase start
   ```
4. The command will output your local credentials:
   ```
   API URL: http://localhost:54321
   anon key: eyJh...
   ```
5. Update your `.env.local` file with these local values:
   ```env
   VITE_SUPABASE_URL=http://localhost:54321
   VITE_SUPABASE_ANON_KEY=your_local_anon_key_here
   ```

### Useful Supabase CLI Commands

- `npx supabase start` - Start local Supabase
- `npx supabase stop` - Stop local Supabase
- `npx supabase status` - Check status
- `npx supabase db reset` - Reset database
- `npx supabase migration new <migration_name>` - Create new migration

## Verify Setup

After configuring your environment variables, test the connection:

```bash
npm run dev
```

Open the browser console and check for any Supabase connection errors.

## Next Steps

1. Create database migrations in `supabase/migrations/`
2. Apply migrations using `npx supabase db push` (cloud) or they auto-apply locally
3. Start building your application!
