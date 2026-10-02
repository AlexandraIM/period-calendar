defmodule PeriodCalendar.Repo.Migrations.CreatePeriodEntries do
  use Ecto.Migration

  def change do
    create table(:period_entries) do
      add :date, :date, null: false
      add :kind, :string, null: false
      add :flow, :string
      add :note, :text
      timestamps()
    end

    create unique_index(:period_entries, [:date, :kind])
  end
end
