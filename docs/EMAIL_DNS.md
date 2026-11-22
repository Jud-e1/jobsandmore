# Email sending (Resend) – DNS records

Sending domain: `mail.jobsandmoreng.com` (Resend, region eu-west-1).
Sender: `JobsAndMore <no-reply@mail.jobsandmoreng.com>`.
Records live in Namecheap → Domain List → jobsandmoreng.com → Advanced DNS.
Hosts are relative to `jobsandmoreng.com`.

| Type  | Host                     | Value |
|-------|--------------------------|-------|
| TXT   | `resend._domainkey.mail` | `p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDd7WawOYIbZ8mIeqxrAC5IiBx++kLqXbtIdFTzgxJvUYCMCld2bzz930zmo0Jcl3PQyPlHNy3T0piBQaFg/qJVWIFBG8NHWGz/w7ZIHNbiFMPs4Zzt5QhsergQZMmN/NCqOe+Lvu9ipakZUd6jI3KJoRyV2L6thQHkvhZDofTFqQIDAQAB` |
| CNAME | `rsend.mail`             | `rsend-euw1.forge.rmta.net` |
| CNAME | `send.mail`              | `send.forge.rmta.net` |
| TXT   | `_dmarc`                 | `v=DMARC1; p=none;` (only if no DMARC record exists yet) |

Receiving (MX `mail` → `receive-euw1.forge.rmta.net`) is not used.
