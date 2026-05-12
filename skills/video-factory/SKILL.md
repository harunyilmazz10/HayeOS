---
name: video-factory
description: Build or operate AI video factories - source ingest, OCR/filter, TTS, subtitles, ffmpeg pipeline, R2/storage, scheduling, multi-platform upload.
---

# Haye Skill: video-factory

## Purpose
Build or maintain "factory" pipelines that produce many short videos per day (500+ videos/month scale from project memory). Ingest, transform, store, schedule, publish.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir; ffmpeg argümanları ve API isimleri orijinal kalır.

## Inputs to inspect first
1. Generation model in use: Sora, Kling, Runway, Wan2.1, or self-hosted (Wan2.1 on Hetzner AX42 is the Haye default).
2. Source/topic strategy: scraped trends, RSS, manual queue, AI-suggested.
3. Storage: R2 / S3 / local; lifecycle policy?
4. Target platforms: YouTube Shorts, TikTok, Instagram Reels — each needs different aspect, length, copy.
5. Pipeline orchestrator: n8n, Celery, Temporal, plain cron, custom?
6. Daily cost ceiling per piece and per day.

## Core design rules

### Pipeline shape
- Stages, each as an idempotent unit with its own retry policy:
  1. **Ideate** (topic / prompt selection)
  2. **Source** (gather raw inputs — clips, images, references)
  3. **Filter** (NSFW, IP, dedup, quality check)
  4. **Script** (LLM writes voiceover + on-screen text)
  5. **Generate** (image/video model produces visuals)
  6. **Voice** (TTS → audio file)
  7. **Subtitle** (ASR or scripted, timed)
  8. **Compose** (ffmpeg assembly)
  9. **QA** (auto checks: duration, audio peak, black-frame, sync)
  10. **Publish** (upload, schedule)
  11. **Track** (post-publish metrics)
- Each stage writes its output to storage with a deterministic key; downstream reads only that key.

### Source and filter
- Scrape sources only with respect to TOS; document the legal posture per source.
- Filter for: NSFW (image classifier), copyrighted music (audio fingerprint), public-figure faces if you're not licensed.
- Dedup: hash of script + hash of source frames against your own history.

### Generation
- Wan2.1 self-hosted: GPU queue management — long-running model loads, batch where possible.
- API-based (Sora, Kling): cost cap per call; retry only on transient errors; fall back to a different model if the primary returns "unsafe" or fails.
- Cache identical generations: a given prompt + seed + version returns the same file; check cache first.

### Voice / subtitle
- TTS: ElevenLabs / OpenAI / self-hosted (e.g., XTTS); voice cloning is a legal hot zone — only for licensed voices.
- Subtitle from script (preferred) is cheaper and more accurate than ASR; if using ASR (Whisper), post-process to enforce maximum chars/line.
- Burn-in subtitles vs separate `.srt`: burn-in for Shorts/Reels (most viewers watch muted); `.srt` for YouTube long-form.

### Compose (ffmpeg)
- Always specify `-pix_fmt yuv420p` for broadest compatibility.
- For vertical 9:16: `-vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920"` and double-check no upscaling artifacts.
- Audio: `-c:a aac -b:a 128k` minimum, `-ar 44100`.
- Add a small per-platform watermark only if licensing requires; otherwise skip — algorithms downrank obvious branding.
- Outputs: `output_<id>.mp4` deterministic; never write to the same key twice (versions instead).

### QA
- Duration matches target ±0.5s.
- Audio peak < -1 dBFS (no clipping); LUFS in -14 to -16 range.
- No black frames > 200ms in body.
- Audio/video offset < 80ms (sync).
- Subtitle text count per second within readable range (3–4 words/sec).

### Publish
- API per platform: YouTube Data API, TikTok Content Posting API, Instagram Graph API.
- Per-platform constraints: title length, hashtag count, schedule lead time.
- Idempotent publish: store `(platform, video_hash) → platform_video_id` so retry never duplicates.
- Schedule, do not auto-fire: let the next pipeline tick publish; lets you cancel mid-queue.

### Storage / lifecycle (R2)
- Tier: hot (last 7 days for re-render), cold (90 days for analytics), archive (1 year, then delete) per platform-TOS.
- Public URL via R2 custom domain or `r2.dev` (rate-limited; not for production).
- Per-file metadata: pipeline run id, stage, prompts, model versions.
- Signed URLs for any private clip.

### Cost guardrails
- Per-video budget: hard fail if exceeded.
- Per-day total budget: pause new pipeline runs.
- Per-model fallback: if Sora is too expensive today, fall back to Wan2.1 self-hosted.

## Common pitfalls
- One bad ffmpeg flag corrupts every output for a week → version-pin ffmpeg in the Docker image, and treat ffmpeg upgrades as risk-gated.
- Two pipelines running on the same source produce dupe content → dedup is at the script-output stage, not just at source.
- TikTok/Instagram shadowban from automation signature → human-feeling cadence, varied lengths, varied hooks; do not post 50 nearly-identical videos in a row.
- Outputs labeled "approved by AI QA" but no human ever watched a sample → keep a 5% random sample for human review.

## Output format
```markdown
## Pipeline state
- stages implemented:
- stages missing:
- last 24h: <produced> / <failed> / <published>

## Findings
- correctness:
- cost:
- compliance/TOS:
- platform-specific issues:

## Suggested next 3
- smallest fix first

## Verification
- end-to-end dry run on one video
- ffmpeg config replays last failure
- platform API in sandbox mode
```

## Safety rules
- Live upload to platforms is a Cost / Risk Gate; require approval per first run and after pipeline changes.
- Never publish content from a source whose TOS prohibits redistribution.
- Never voice-clone a real person without documented consent.
- Wan2.1 / GPU model loads are slow; do not run a "test" generation during a real publish window without a sandbox path.
- Long pipeline specs go to `docs/video-pipeline.md`; chat gets the summary.
