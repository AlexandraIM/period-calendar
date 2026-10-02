defmodule PeriodCalendar.Components.Icons do
  @moduledoc "Phosphor icon helpers. Font registered as :phosphor in App."

  # codepoints from @phosphor-icons/web src/regular/selection.json
  @icons %{
    calendar: 0xE108,
    caret_left: 0xE138,
    caret_right: 0xE13A,
    caret_down: 0xE136,
    drop: 0xE210,
    lock: 0xE2FA,
    gear: 0xE270,
    chart_bar: 0xE150,
    plus: 0xE3D4,
    minus: 0xE32A
  }

  def icon(name, size \\ :lg, color \\ :on_surface) when is_atom(name) do
    code = Map.fetch!(@icons, name)
    glyph = <<code::utf8>>

    %{
      type: :text,
      props: %{
        text: glyph,
        text_size: size,
        text_color: color,
        font: :phosphor,
        text_align: "center"
      },
      children: []
    }
  end

  def icon_button(name, tap, opts \\ []) do
    size = Keyword.get(opts, :size, :lg)
    color = Keyword.get(opts, :color, :on_surface)
    bg = Keyword.get(opts, :background, :surface_raised)

    %{
      type: :box,
      props: %{background: bg, corner_radius: :radius_md, padding: :space_sm, on_tap: tap},
      children: [icon(name, size, color)]
    }
  end
end
