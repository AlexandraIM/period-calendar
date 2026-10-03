# Repository guidance

- This is a single Elixir/Mob mobile app. `src/period_calendar.erl` bootstraps the BEAM, then `PeriodCalendar.App` (`lib/period_calendar/app.ex`) starts `PeriodCalendar.LockScreen`; screen and cycle logic live in `lib/period_calendar/`.
- SQLite migrations live in `priv/repo/migrations/`. On devices Mob deploys BEAMs flat, so `PeriodCalendar.App` must use `MOB_BEAMS_DIR/priv/repo/migrations`; keep the host `Application.app_dir/2` fallback for Mix runs.
- `PeriodCalendar.Repo` stores data under `MOB_DATA_DIR`, but falls back to `$HOME/app.db`. The test helper starts and migrates the real SQLite repo, so always isolate tests with a fresh `MOB_DATA_DIR`:
  - All tests: `MOB_DATA_DIR="$(mktemp -d)" mix test`
  - Focused suite: `MOB_DATA_DIR="$(mktemp -d)" mix test test/period_calendar/home_screen_test.exs`
- Use the versions pinned in `.tool-versions` (`mise install`); the Zig dev snapshot is deliberate and Java 17 is required for Gradle.
- Mob-specific setup: run `mix deps.get`, then `mix mob.install`, then `mix mob.doctor`. `mix format` uses `Mob.Formatter`; the standard local checks are `mix format`, isolated `mix test`, `mix compile --warnings-as-errors`, and `mix credo --strict`.
- Native capability dependencies must also be activated in `mob.exs` under `config :mob, :plugins`; `mob.exs` is shared project config, while machine-specific overrides belong in ignored `mob.local.exs`.
