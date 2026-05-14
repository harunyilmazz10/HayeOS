---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** Tell your human partner that HayeOS works much better with access to subagents. The quality of its work will be significantly higher if run on a platform with subagent support (such as Claude Code or Codex). If subagents are available, use haye:subagent-driven-development instead of this skill.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use haye:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **haye:using-git-worktrees** - Ensures isolated workspace (creates one or verifies existing)
- **haye:writing-plans** - Creates the plan this skill executes
- **haye:finishing-a-development-branch** - Complete development after all tasks


## HayeOS Layer (added in v3.0.0)

### User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, sorular, özetler, uyarılar Türkçe verilecek.
- Skill içeriği İngilizce kalır, sadece kullanıcıya verilen yanıt Türkçe.
- Code, file paths, package names, technical identifiers stay in English.

### Memory Vault Integration
- Plans (writing-plans output) save to: `<resolved memoryPath>/04-plans/YYYY-MM-DD-<feature>.md`
- Specs (brainstorming output) save to: `<resolved memoryPath>/02-decisions/YYYY-MM-DD-<feature>-spec.md`
- Review notes (subagent-driven-development) save to: `<resolved memoryPath>/10-reviews/<task-id>/`
- Always resolve `<resolved memoryPath>` from `.hayeos.json` before writing.
- If `.hayeos.json` is missing, STOP and ask user to run `/haye:start` first.

### Path Separation Rule
- Source code -> sourcePath (project root)
- Memory artifacts -> memoryPath (vault, `<project>_obs/`)
- Never write source code under memoryPath. Never write memory artifacts under sourcePath.

