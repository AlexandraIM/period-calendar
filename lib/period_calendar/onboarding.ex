defmodule PeriodCalendar.Onboarding do
  @moduledoc "First-run preferences stored locally via Mob.State."

  def onboarded?, do: Mob.State.get(:onboarded, false)

  def cycle_length, do: Mob.State.get(:cycle_length, 28)
  def period_length, do: Mob.State.get(:period_length, 5)

  def complete(cycle_length, period_length)
      when is_integer(cycle_length) and is_integer(period_length) do
    Mob.State.put(:cycle_length, clamp(cycle_length, 21, 35))
    Mob.State.put(:period_length, clamp(period_length, 2, 8))
    Mob.State.put(:onboarded, true)
    :ok
  end

  def reset do
    Mob.State.delete(:onboarded)
    Mob.State.delete(:cycle_length)
    Mob.State.delete(:period_length)
    :ok
  end

  defp clamp(value, min, max), do: value |> max(min) |> min(max)
end
