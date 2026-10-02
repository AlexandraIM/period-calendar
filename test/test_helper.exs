ExUnit.start()

{:ok, _} = Application.ensure_all_started(:ecto_sqlite3)
{:ok, _} = PeriodCalendar.Repo.start_link()

Ecto.Migrator.run(
  PeriodCalendar.Repo,
  Application.app_dir(:period_calendar, "priv/repo/migrations"),
  :up,
  all: true
)
