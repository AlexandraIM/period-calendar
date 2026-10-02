defmodule PeriodCalendar.PeriodEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "period_entries" do
    field(:date, :date)
    field(:kind, :string)
    field(:flow, :string)
    field(:note, :string)
    timestamps()
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:date, :kind, :flow, :note])
    |> validate_required([:date, :kind])
    |> unique_constraint([:date, :kind])
  end
end
