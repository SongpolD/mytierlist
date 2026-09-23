# My Top 10 — public site with owner-only editing

Visitors can view and filter the list. The owner can sign in by email magic link to add, delete, reorder, and change poster links. Authorization is enforced by Supabase Row Level Security as well as by the interface.

## Configure Supabase

1. Open **SQL Editor**, open `supabase-schema.sql`, replace `OWNER_EMAIL` with the owner's exact email address, then run the SQL. It creates a private owner allow-list, public read access, owner-only write rules, and starter rows. The email is entered only in Supabase and is not published in this repository.
2. In Supabase **Authentication → URL Configuration**, add the GitHub Pages URL to the allowed redirect URLs.
3. In **Project Settings → API Keys**, copy the Project URL and the **publishable** key into `config.js`. Never use a secret/service-role key in this file. The publishable key is expected to be public; database rules are enforced by RLS.
4. In Supabase Auth, configure email sign-in and your email provider.

## Publish on GitHub Pages

1. Put `index.html`, `config.js`, and the other project files in the GitHub repository. Keep `config.js` as a publishable-key-only file; it contains no database secret.
2. In repository **Settings → Pages**, choose **GitHub Actions** as the build and deployment source.
3. Once GitHub shows the public URL, add that URL to Supabase's allowed redirect URLs.

The table is the source of truth after setup; `data.json` is only the starter-list reference. Updates made by the owner in the site are immediately stored online and appear to public visitors.
