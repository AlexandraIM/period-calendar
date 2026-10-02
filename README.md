# Luna — Period Calendar

Local-first period calendar built with [Mob](https://mobframework.com) (Elixir + BEAM on device). All data stays on the device — no account, no tracking, no upload.

Design direction: **Warm Botanical** — parchment/ivory surfaces, deep aubergine text, berry-plum accent, light-pink predictions — via [Mishka Chelekom](https://mishka.tools/chelekom) + `mob_mishka` components. Icons via [Phosphor](https://phosphoricons.com).

## Features

- **First-run onboarding** — typical cycle length (21–35 days) and period length (2–8 days), persisted in `Mob.State` (`lib/period_calendar/onboarding.ex`)
- **Private by default** — `LockScreen` with `mob_biometric` (Face ID / Touch ID / system biometrics), `Info.plist` `NSFaceIDUsageDescription`; simulator fallback `Continue without biometrics`
- **Today** — current cycle day, one-tap `Log period start`, idempotent `Cycle.log_period_start/2` (`lib/period_calendar/cycle.ex`, `period_entry.ex`)
- **Calendar** — reusable `Components.Calendar.month_grid/3` (`lib/period_calendar/components/calendar.ex`), month nav `1:2:1` (prev / month / next), logged = berry `primary`, predicted = light pink `0xFFFACED9`
- **Predictions** — `Cycle.predicted_period_dates/1` expands `latest_period + n*cycle_length` for 6 cycles, filtered to the visible month
- **Flow logging** — `LogScreen` with Light/Medium/Heavy
- **Offline & local** — Ecto + SQLite (`ecto_sqlite3`/`exqlite`), migrations in `priv/repo/migrations/`, DB path via `MOB_DATA_DIR` / `MOB_BEAMS_DIR` (`lib/period_calendar/repo.ex`, `app.ex:migrations_dir/0`)

## Tech Stack

- `mob ~> 0.9.10`, `mob_dev ~> 0.7.9`, `mob_new 0.6.3`
- `ecto_sqlite3 ~> 0.25 / exqlite`, `mob_biometric`, `mob_themes`, `mob_mishka ~> 0.1.3`
- Fonts: `Phosphor` + `Phosphor-Light` TTF in `priv/fonts/` registered as `phosphor` in `Mob.App` (`lib/period_calendar/app.ex`, `lib/period_calendar/components/icons.ex`)
- Theme: `{Mob.Theme.Light, primary: :rose_500, background: 0xFFFFFAF7, ... radius_lg: 18}` with `Mob.Theme.set/1` on start

## Project Structure

```
lib/period_calendar/
  app.ex                 # Mob.App entry, theme + fonts, navigation root LockScreen
  lock_screen.ex         # biometric gate → Onboarding or Home
  onboarding_screen.ex   # cycle/period steppers → Home
  onboarding.ex          # Mob.State wrapper (cycle_length, period_length, onboarded)
  home_screen.ex         # Today + Cycle + Log + Calendar/Log nav
  calendar_screen.ex     # month nav (1:2:1) + Calendar.month_grid
  log_screen.ex          # flow picker
  cycle.ex               # Repo queries + predictions
  period_entry.ex        # Ecto schema period_entries
  repo.ex                # Ecto SQLite repo
  components/
    calendar.ex          # reusable month grid (padded weeks, gap:4, h:36)
    icons.ex             # Phosphor codepoints (caret_left/right, calendar, etc.)
priv/
  repo/migrations/       # period_entries + mob_screen_states
  fonts/Phosphor*.ttf
ios/  # build.zig / build_device.zig / AppDelegate.m / Info.plist
android/
```

## Requirements

Pinned in `.tool-versions` (mise/asdf):

```
erlang 29.0
elixir 1.20.0-otp-29
java temurin-17.0.18   # Gradle needs 17–21 (Android Studio bundles 25, use 17 for AGP)
zig 0.17.0-dev.269+ebff43698
```

Also: Xcode 15+, Android Studio + SDK, `adb`, `.mob/toolchain` (arm64 on Apple Silicon, see `~/.mob/toolchain/env.sh`).

## Getting Started

```bash
# 1. Deps + OTP runtimes + placeholder icons
mix deps.get
mix mob.install

# 2. Verify
mix mob.doctor

# 3. iOS simulator
xcrun simctl boot "iPhone 18 Pro"
open -a Simulator
mix mob.deploy --native --ios   # first time: builds .app
mix mob.deploy --ios            # later: push BEAMs only

# 4. Android (emulator or USB with USB Debugging + File Transfer)
mix mob.deploy --native --android
mix mob.deploy --android

# 5. Both platforms
mix mob.deploy --native
```

Physical iPhone (once): enable Developer Mode on device, trust Mac, then `mix mob.provision` before deploy.

## Development

```bash
mix format && mix test && mix compile --warnings-as-errors

# live reload
mix mob.watch          # auto-push on file save
mix mob.connect        # IEx over dist (inspect, nl(Module), Mob.Test.*)
mix mob.push           # hot-push without restart (dist)
mix mob.deploy --ios   # push + restart

mix mob.cache          # inspect/clear ~/.mob/cache
```

Simulator biometrics: Simulator → Features → Face ID → Enrolled, then Features → Face ID → Matching Face when prompted. Or use the on-screen “Continue without biometrics (simulator)”.

Reset onboarding for testing via IEx: `PeriodCalendar.Onboarding.reset()`.

## Privacy & Data

- SQLite at `MOB_DATA_DIR/app.db` (app-private, app survives updates)
- No network for cycle data; `Mob.State` + Repo both on-device
- Planned: SQLCipher layer via `exqlite` `:key` + Keystore/Keychain for encrypted DB (see `ecto_sqlite3` README Database Encryption)

## Icons & Theming

Phosphor Regular/Light TTFs from `@phosphor-icons/web` 2.1.2 (`src/regular/Phosphor.ttf` etc.), codepoints from `selection.json` (e.g. `calendar 0xE108`, `caret-left 0xE138`). Use via `Icons.icon/3` (`font: :phosphor`). Warm Botanical palette + Mishka tokens; light/dark via `Mob.Theme.set/1`.

## License

Private app scaffold — adapt license as needed.
