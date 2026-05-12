# Recipe: Video Factory

Quick reference. Full design via `video-factory` skill.

## Stack assumed
- Wan2.1 self-hosted on Hetzner AX42 OR Sora/Kling API
- ffmpeg pipeline, R2 storage
- Target: YouTube Shorts, TikTok, Reels (vertical 9:16)
- 500+ videos/month scale

## Pipeline stages (each idempotent)
1. Ideate → 2. Source → 3. Filter → 4. Script → 5. Generate
6. Voice → 7. Subtitle → 8. Compose → 9. QA → 10. Publish → 11. Track

## ffmpeg essentials
- `-pix_fmt yuv420p` for compatibility
- Vertical: `scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920`
- Audio: `-c:a aac -b:a 128k -ar 44100`
- LUFS target: -14 to -16

## QA auto-checks
- Duration matches target ±0.5s
- Audio peak < -1 dBFS
- No black frames >200ms in body
- Audio/video offset < 80ms

## Cost guardrails
- Per-video hard budget
- Per-day total hard budget
- Per-model fallback (Sora expensive → Wan2.1)

## Compliance
- Source TOS respected; no copyrighted music
- No voice-cloning real people without consent
- 5% random sample reviewed by human

## When to escalate
- Pipeline design → `video-factory` skill
- Storage → see `cloudflare-r2.md`
- n8n orchestration → `n8n-pipeline` skill
