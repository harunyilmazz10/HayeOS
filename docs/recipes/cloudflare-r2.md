# Recipe: Cloudflare R2 (S3-compatible storage)

Quick reference for using R2 as primary object storage.

## Stack assumed
- Cloudflare R2 bucket per environment (`<project>-prod`, `<project>-staging`)
- S3-compatible API via SDK (`@aws-sdk/client-s3` or `boto3`)
- Custom domain or `r2.dev` (rate-limited; not for production)

## Credential shape
- Account ID, Access Key ID, Secret Access Key per bucket scope
- Endpoint: `https://<account-id>.r2.cloudflarestorage.com`
- Region: `auto`

## Access patterns
- Private bucket + signed URLs (default, recommended)
- Public bucket via custom domain (use Worker for auth if needed)
- NEVER make a private bucket public to fix a 401; signed URL or Worker

## Upload pattern
- Direct multipart upload from server for >5MB
- Presigned PUT URLs for browser uploads — generated server-side, scoped to specific key

## Lifecycle
- Hot (last 7 days) → cold (90 days) → archive (1 year) → delete
- Set per-prefix rules in R2 dashboard or via API

## Cost notes
- Egress: $0 within Cloudflare network (Workers, Pages)
- Class A (writes) and Class B (reads) operations metered
- Storage at-rest cheap; cold tier even cheaper

## Common breakage
- Public URL 401 → not a public bucket; use signed URL or Worker
- Signed URL expired → server clock skew; signed URLs are time-bound
- Multipart abandoned → set lifecycle rule to clean incomplete uploads after 7 days

## When to escalate
- Cloudflare-side issues → `cloudflare-doctor`
- File pipeline integration → `video-factory` or `content-automation`
