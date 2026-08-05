# Privacy Policy — DataVault

**Last updated:** August 5, 2026  
**Operator:** DataWithPranav (Pranav Verma)  
**Service:** DataVault — Instagram comment keyword → private reply with a learning resource link

This privacy policy describes how DataVault (“we”, “us”) handles information when people interact with our Instagram content and when we operate the DataVault application connected to Meta / Instagram APIs.

---

## 1. What DataVault does

When someone comments a configured keyword (for example `DATASET`) on a bound Instagram Reel or post, DataVault may send a **private reply** containing a link to a publicly available learning resource (typically a GitHub URL). Resource files themselves are hosted on public GitHub; DataVault stores URLs and reply text, not binary file uploads for end users.

---

## 2. Information we process

### From Instagram / Meta (via webhooks and Graph API)

When a relevant comment event is delivered to our server, we may process and store:

- Instagram **comment ID**
- Instagram **media / Reel ID** the comment was left on
- **Comment text**
- **Instagram username** (if provided by Meta in the event)
- Timestamps of the comment and of any private-reply attempt
- Outcome of delivery (sent, skipped, failed) for operational logging

We also use Instagram API credentials belonging to the DataWithPranav professional account (access tokens, account IDs) to list media for admin configuration and to send private replies. Those credentials are server-side secrets and are not shared with commenters.

### Admin / operator data

The operator may store configuration such as:

- Resource names, GitHub URLs, and message templates
- Reel bindings (media ID + keyword → resource)

Admin access to the API is protected by an API key. We do not run a public end-user signup for followers.

### What we do **not** collect from followers

- Passwords
- Email addresses (unless someone separately emails us)
- Payment or billing information
- Precise device location
- Contacts, photos, or files from a follower’s device

---

## 3. How we use information

We use the information above only to:

- Match a comment to the correct Reel + keyword binding
- Send one private reply with the bound resource message/URL
- Prevent duplicate replies for the same comment
- Operate, debug, and secure the service (activity logs)
- Comply with Meta platform policies and applicable law

We do **not** sell personal information. We do **not** use comment data for advertising profiles or resale to data brokers.

---

## 4. Sharing and third-party processors

We share or transmit data only as needed to run the service:

| Party | Role |
|-------|------|
| **Meta / Instagram** | Delivers comment webhooks; receives private-reply API calls |
| **Hosting provider** (e.g. Render) | Runs the DataVault application |
| **Database provider** (e.g. Neon / PostgreSQL) | Stores configuration and activity logs |
| **GitHub** | Hosts public resource files linked in replies |

These providers process data under their own terms and security practices. We do not authorize them to use DataVault comment logs for their own marketing.

---

## 5. Retention

- Configuration (resources, bindings) is kept while the service is operated.
- Comment and reply logs are retained for delivery, deduplication, debugging, and abuse prevention. We may delete or anonymize older logs periodically.

Access tokens and secrets are rotated or revoked when no longer needed.

---

## 6. Your choices and deletion

If you commented on our Instagram content and want related log data removed, contact us (see below) with your Instagram username and approximate date of the comment. We will delete or anonymize identifiable log entries where reasonably possible, except where we must retain records for security, fraud prevention, or legal obligations.

You can also delete your own Instagram comments in the Instagram app; that does not automatically erase copies already stored in our logs until we process a deletion request or purge logs.

---

## 7. Security

We use HTTPS for our public API, restrict admin endpoints with an API key, verify Meta webhook signatures where configured, and limit Instagram tokens to server-side use. No method of transmission or storage is 100% secure.

---

## 8. Children’s privacy

DataVault is not directed at children under 13, and we do not knowingly collect personal information from children under 13. Instagram’s own age and platform rules also apply.

---

## 9. Changes

We may update this policy from time to time. The “Last updated” date at the top will change when we do. Continued use of the Instagram automation after an update means the revised policy applies to ongoing processing.

---

## 10. Contact

For privacy questions or deletion requests related to DataVault:

- Instagram: [@DataWithPranav](https://www.instagram.com/) (DataWithPranav)
- Project / issues: the DataVault GitHub repository associated with this policy

If you need a dedicated email address listed here, add it in App Dashboard contact settings and keep this document in sync.
