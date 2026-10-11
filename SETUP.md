# Putting Dead Air on the air

This takes about 30–45 minutes, once. Everything here is free. You'll create three free accounts:

- **Supabase** stores your content, your images and your Control Room sign-in.
- **GitHub** holds the site's files.
- **Cloudflare** publishes the site at a public address.

Your current content is already in the package: the stations, broadcasts (including your Spotify playlists and the WDRD cover), staff, notices, weather and site text.

---

## Part 1 — Supabase (your content)

1. Go to **supabase.com** and sign up.
2. Click **New project**.
   - Name it `dead-air`.
   - Make up a database password and save it somewhere safe. You won't need it day to day.
   - Pick the region closest to you.
   - Click **Create**. Wait a minute or two while it gets ready.
3. Run the setup script:
   - In the left sidebar, open **SQL Editor** and click **New query**.
   - Open `supabase/schema.sql` from this package, copy all of it, paste it in, and click **Run**.
   - You should see "Success. No rows returned".
4. Load your content the same way: start a new query, paste all of `supabase/seed.sql`, and click **Run**.
5. Tell the database who owns the station. Start a new query and paste this line, using **your own email address**:
   ```sql
   insert into public.site_owner (email) values ('you@example.com');
   ```
   Click **Run**.
6. Create your sign-in account:
   - Go to **Authentication → Users**.
   - Click **Add user → Create new user**.
   - Enter the same email address and any password; you won't use the password.
   - Tick **Auto Confirm User** and click **Create user**.
7. Stop strangers from creating accounts:
   - Go to **Authentication → Sign In / Providers**.
   - Turn **off** "Allow new users to sign up" and click **Save**.

   Even without this step, other accounts can never change anything, but turning it off keeps things tidy.
8. *(Recommended)* Get a sign-in code in your email, so you can read the email on your phone and sign in on your computer:
   - Go to **Authentication → Emails → Magic Link**.
   - Add this line anywhere in the message body: `Your code: {{ .Token }}`
   - Click **Save**.
9. Copy two values for later:
   - Go to **Project Settings → API Keys**.
   - Copy the **Project URL**.
   - Copy the **anon public** key. If you only see new-style keys, it's under the **Legacy API keys** tab.
   - Never use the key labeled **service_role** or **secret**.

## Part 2 — Fill in config.js

Open `config.js` in any text editor (Notepad or TextEdit is fine). Replace the two placeholders with the values you copied, keeping the quote marks:

```js
window.DEADAIR_CONFIG = {
  supabaseUrl: "https://abcdefgh.supabase.co",
  supabaseAnonKey: "eyJhbGciOi...long key..."
};
```

Save the file. Both values are designed to be public; your database rules protect everything.

## Part 3 — GitHub (the site's files)

1. On **github.com**, click **+ → New repository**.
   - Name it `dead-air`.
   - Public or private both work.
   - Click **Create repository**.
2. On the new repository's page, click **uploading an existing file**.
   - Drag in everything from this package: `index.html`, `config.js`, `_headers`, `SETUP.md`, `README.md`, and the `images` and `supabase` folders.
   - Click **Commit changes**.
3. Add the keep-awake job. This stops free Supabase from pausing your site after a quiet week.
   - Click **Add file → Create new file**.
   - Name it exactly `.github/workflows/keep-awake.yml`. Typing the slashes creates the folders.
   - Paste in the contents of `.github/workflows/keep-awake.yml` and click **Commit changes**.

## Part 4 — Cloudflare (the public address)

1. Sign up at **dash.cloudflare.com**.
2. Go to **Workers & Pages → Create**.
   - Choose the **Pages** tab, then **Connect to Git** (it may say "Import an existing Git repository").
   - Connect your GitHub account and pick the `dead-air` repository.
3. Build settings:
   - **Framework preset:** None
   - **Build command:** leave empty
   - **Build output directory:** `/`
4. Click **Save and Deploy**. After a minute you'll get an address like `dead-air.pages.dev`. That's your public site.

## Part 5 — Connect the two

1. Back in Supabase, go to **Authentication → URL Configuration**.
2. Set **Site URL** to your Cloudflare address, for example `https://dead-air.pages.dev`.
3. Also add it under **Redirect URLs**.
4. Click **Save**.

## Part 6 — Try it

1. Visit your Cloudflare address. You should see the receiver scan, then the site, with no sign-in.
2. Scroll to the footer and click **Control Room**. Enter your email and click **Send sign-in email**.
3. Sign in using the link in the email (open it in the same browser) or by typing the code.
4. Make a small change and click **Publish**. Then open the site on your phone; the change should be there.
5. Start the keep-awake job once by hand: in GitHub, open the **Actions** tab, choose **Keep the transmitter warm**, then **Run workflow**. It shows a green tick when it works.

---

## Good to know

- **Day-to-day updates** (playlists, notices, staff, weather, text) all happen in the Control Room. Changes appear for visitors immediately. No rebuilding needed.
- **Changing the design or features:** come back to Claude and ask. You'll get updated files to upload to GitHub (**Add file → Upload files**, replacing the old ones). Cloudflare republishes automatically within a minute.
- **If the site says the listings are "out of range":** the database has probably paused. In Supabase, open the project and click **Restore**. The keep-awake job should prevent this.
- **GitHub pauses scheduled jobs** in repositories that see no changes for 60 days. It emails you first, and re-enabling is one click in the **Actions** tab.
- **Free limits:** 1 GB of images and 5 GB of downloads a month on Supabase, which is plenty for this site, since images are resized when you upload them. Cloudflare's free hosting has no bandwidth limit.
- **Your own domain** (like `deadairradio.com`) is optional. Buy it from any registrar, roughly $10–15 a year, then add it in Cloudflare under your Pages project → **Custom domains**. Then update the Site URL in Supabase (Part 5).
