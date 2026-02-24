# wakasync

Daily archival of WakaTime data via GitHub Actions. WakaTime's free plan retains only 7 days of data — this repo fetches and commits it daily so nothing is lost.

## How it works

A scheduled GitHub Actions workflow runs `sync.sh` nightly, which:

1. Loops over the last 7 days
2. Skips days that already have data archived
3. Fetches summaries, durations, and stats from the WakaTime API
4. Saves pretty-printed JSON under `data/YYYY/MM/DD/`
5. Commits and pushes any new data

## Data structure

```
data/
└── 2026/
    └── 02/
        └── 24/
            ├── summary.json     # /v1/users/current/summaries
            ├── durations.json   # /v1/users/current/durations
            └── stats.json       # /v1/users/current/stats/last_7_days (today only)
```

## Setup

1. Push this repo to GitHub
2. Add your WakaTime API key as a repository secret named `WAKATIME_API_KEY`
3. The workflow runs automatically at 11:55 PM ET daily, or trigger it manually via the Actions tab

## Local usage

```bash
export WAKATIME_API_KEY="YOUR_WAKATIME_API_KEY_HERE"
export WAKATIME_API_URL="https://wakatime.com/api/v1"
bash sync.sh
```
