# Public build settings

`public_env.json` holds the values the web and mobile apps are built with
(`--dart-define-from-file=config/public_env.json`).

Everything here is **public by design**: the Supabase *publishable* key only
allows what the database's row-level security policies allow. Never put the
`service_role` / secret key, Paystack secret key or any other secret in this
folder — secrets belong in Supabase Edge Function secrets.
