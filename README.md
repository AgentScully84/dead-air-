# Dead Air Broadcasting Cooperative

An independent collection of imaginary radio stations transmitting from somewhere nearby. Real playlists, unusual reception.

- `index.html` is the whole site: public pages plus the owner-only Control Room.
- `config.js` holds the Supabase project address and public key.
- `supabase/schema.sql` creates the database, the owner-only editing rules and the image storage.
- `supabase/seed.sql` holds the starting content.
- `images/` holds images shipped with the site.
- `.github/workflows/keep-awake.yml` pings the database every few days so the free project doesn't pause.

Setup instructions are in **SETUP.md**.

Hosting: Cloudflare Pages (static, no build step) and Supabase (database, sign-in, image storage). Editing permissions are enforced by the database's row-level security, not by the page.
