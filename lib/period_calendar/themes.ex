defmodule PeriodCalendar.Themes do
  @warm_light {
    Mob.Theme.Light,
    primary: :rose_500,
    background: 0xFFFFFAF7,
    surface: 0xFFFFFDFC,
    surface_raised: 0xFFF1E8E7,
    on_surface: 0xFF291E2B,
    muted: 0xFF756A75,
    border: 0xFFE5DCD5,
    radius_lg: 18
  }

  @warm_dark {
    Mob.Theme.Dark,
    primary: :rose_300,
    background: 0xFF1A1416,
    surface: 0xFF2A1F22,
    surface_raised: 0xFF3A2E33,
    on_surface: 0xFFF5E6E8,
    muted: 0xFFB8A6A9,
    border: 0xFF4A3539,
    radius_lg: 18
  }

  def light, do: @warm_light
  def dark, do: @warm_dark

  def current do
    case Mob.State.get(:theme, :light) do
      :dark -> dark()
      _ -> light()
    end
  end

  def current_key, do: Mob.State.get(:theme, :light)

  def set(key) when key in [:light, :dark] do
    theme = if key == :dark, do: dark(), else: light()
    Mob.Theme.set(theme)
    Mob.State.put(:theme, key)
    :ok
  end
end
