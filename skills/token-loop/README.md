# token-loop

## Problem

Claude Pro gives 200,000 tokens per 5-hour window. The window only **starts when you send your first message** after a reset — it doesn't tick down while you're idle.

If you forget to open Claude right after a reset, you lose that head start. By the time you sit down to work, your window is already shrinking.

## Solution

`token-loop` automatically sends the first message 1 minute after each reset, starting the window without you having to think about it.

It works in two stages:

**1. Bootstrap** (one-shot, runs once at reset+1min)
Fires at the exact right moment, prints the time, and creates the recurring routine below.

**2. Cron routine** (runs every 5h forever)
A lightweight cloud session — Haiku model, no context, no sources — that just marks each new window cycle.

Each cloud run prints:
```
2026-07-02 00:01:03 SGT
2026-07-01 16:01:03 UTC
Claude Pro token window started
```

## Install

```bash
npx skills add pdkproitf/skills@token-loop --global
```

## Usage

Run once per window cycle to align the bootstrap to your actual reset time:

```
/token-loop
```

The skill reads your reset time from `claude /usage`, schedules the bootstrap at reset+1min, and the bootstrap handles everything after that.

## How it works

```
/token-loop
    └── reads reset time from claude /usage
    └── creates bootstrap routine  →  fires at reset+1min
                                          └── prints SGT + UTC time
                                          └── prints "Claude Pro token window started"
                                          └── creates cron routine  →  fires every 5h
                                                                            └── prints SGT + UTC time
                                                                            └── prints "Claude Pro token window started"
```

## Manage

View or stop routines: https://claude.ai/code/routines
