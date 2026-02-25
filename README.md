# wakasync

Daily archival of WakaTime data via GitHub Actions. WakaTime's free plan retains only 7 days of data — this action fetches and commits it daily so nothing is lost.

## Why?

WakaTime's free tier only keeps 7 days of history. wakasync archives your stats daily to a GitHub repo, giving you:

- **Permanent history** — Never lose your coding stats
- **Historical browsing** — View past weeks in [wakadash](https://github.com/b00y0h/wakadash)
- **Data ownership** — Your stats in your repo

## Used By

- **[wakadash](https://github.com/b00y0h/wakadash)** — Terminal dashboard that reads archived data for historical navigation

Configure wakadash to use your archive:

```ini
# ~/.wakatime.cfg
[wakadash]
history_repo = your-username/your-wakatime-archive
```

Then press `←` in wakadash to browse historical weeks.

## How It Works

A scheduled GitHub Actions workflow runs `sync.sh` nightly, which:

1. Loops over the last 7 days
2. Skips days that already have data archived
3. Fetches summaries, durations, and stats from the WakaTime API
4. Saves pretty-printed JSON under `data/YYYY/MM/DD/`
5. Commits and pushes any new data

## Data Structure

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

1. Fork or copy this repo to your GitHub account
2. Add your WakaTime API key as a repository secret named `WAKATIME_API_KEY`
3. The workflow runs automatically at 11:55 PM ET daily, or trigger manually via Actions tab

### Finding Your API Key

1. Go to [wakatime.com/settings/api-key](https://wakatime.com/settings/api-key)
2. Copy your Secret API Key
3. Add it as a GitHub repository secret

## Local Usage

```bash
export WAKATIME_API_KEY="your-api-key-here"
export WAKATIME_API_URL="https://wakatime.com/api/v1"
bash sync.sh
```

## Related Projects

- **[wakadash](https://github.com/b00y0h/wakadash)** — Beautiful terminal dashboard for WakaTime stats with historical data navigation

## License

MIT
