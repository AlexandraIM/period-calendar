defmodule PeriodCalendar.Cycle do
  @moduledoc "Small, deterministic cycle domain API backed by local SQLite."
  import Ecto.Query
  alias PeriodCalendar.PeriodEntry

  def latest_period do
    PeriodCalendar.Repo.one(
      from(entry in PeriodEntry,
        where: entry.kind == "period_start",
        order_by: [desc: entry.date],
        limit: 1
      )
    )
  end

  def logged_today? do
    today = Date.utc_today()

    PeriodCalendar.Repo.exists?(
      from(entry in PeriodEntry,
        where: entry.kind == "period_start" and entry.date == ^today
      )
    )
  end

  def period_dates do
    PeriodCalendar.Repo.all(
      from(entry in PeriodEntry,
        where: entry.kind == "period_start",
        select: entry.date
      )
    )
  end

  def log_period_start(date, flow \\ "unknown") do
    %PeriodEntry{}
    |> PeriodEntry.changeset(%{date: date, kind: "period_start", flow: flow})
    |> PeriodCalendar.Repo.insert(
      on_conflict: [set: [flow: flow, updated_at: NaiveDateTime.utc_now()]],
      conflict_target: [:date, :kind]
    )
  end

  def predicted_period_dates(month) do
    case latest_period() do
      nil ->
        []

      %{date: start} ->
        cycle = PeriodCalendar.Onboarding.cycle_length()
        length = PeriodCalendar.Onboarding.period_length()
        month_start = Date.beginning_of_month(month)
        month_end = Date.end_of_month(month)

        1..6
        |> Enum.flat_map(fn n ->
          s = Date.add(start, n * cycle)
          Enum.map(0..(length - 1), &Date.add(s, &1))
        end)
        |> Enum.filter(
          &(Date.compare(&1, month_start) != :lt and Date.compare(&1, month_end) != :gt)
        )
        |> Enum.uniq()
    end
  end

  def predicted_ovulation_dates(month) do
    case latest_period() do
      nil ->
        []

      %{date: start} ->
        cycle = PeriodCalendar.Onboarding.cycle_length()
        month_start = Date.beginning_of_month(month)
        month_end = Date.end_of_month(month)

        1..6
        |> Enum.flat_map(fn n ->
          s = Date.add(start, n * cycle)
          ov = Date.add(s, -14)
          # show 3-day ovulation window: day before, ovulation, day after
          [Date.add(ov, -1), ov, Date.add(ov, 1)]
        end)
        |> Enum.filter(
          &(Date.compare(&1, month_start) != :lt and Date.compare(&1, month_end) != :gt)
        )
        |> Enum.uniq()
    end
  end
end
