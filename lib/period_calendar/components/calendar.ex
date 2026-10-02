defmodule PeriodCalendar.Components.Calendar do
  @moduledoc "Reusable month grid. Renders period (berry) and predicted (light pink) days."
  alias PeriodCalendar.I18n

  def month_grid(month, periods, predictions, ovulations \\ []) do
    days = month_days(month)

    %{
      type: :column,
      props: %{fill_width: true},
      children: [
        %{
          type: :row,
          props: %{fill_width: true},
          children: Enum.map(~w[M T W T F S S], &day_label/1)
        },
        %{type: :spacer, props: %{size: 8}, children: []},
        %{
          type: :column,
          props: %{fill_width: true},
          children:
            days |> Enum.chunk_every(7) |> Enum.map(&week(&1, periods, predictions, ovulations))
        },
        %{type: :spacer, props: %{size: 12}, children: []},
        legend()
      ]
    }
  end

  def month_days(month) do
    blanks = List.duplicate(nil, Date.day_of_week(month) - 1)
    blanks ++ Enum.map(1..Date.days_in_month(month), &Date.new!(month.year, month.month, &1))
  end

  defp week(days, periods, predictions, ovulations) do
    padded = days ++ List.duplicate(nil, 7 - length(days))

    %{
      type: :row,
      props: %{fill_width: true, gap: 4},
      children: Enum.map(padded, &day_cell(&1, periods, predictions, ovulations))
    }
  end

  defp day_cell(nil, _periods, _predictions, _ovulations),
    do: %{type: :spacer, props: %{weight: 1, height: 36}, children: []}

  defp day_cell(date, periods, predictions, ovulations) do
    is_period = date in periods
    is_predicted = date in predictions
    is_ovulation = date in ovulations

    {background, color} =
      cond do
        is_period -> {:primary, :on_primary}
        is_ovulation -> {0xFFD3EFDA, :on_surface}
        is_predicted -> {0xFFFACED9, :on_surface}
        true -> {:surface, :on_surface}
      end

    %{
      type: :box,
      props: %{
        weight: 1,
        height: 36,
        background: background,
        corner_radius: :radius_md,
        padding: :space_sm
      },
      children: [
        %{
          type: :text,
          props: %{
            text: Integer.to_string(date.day),
            text_size: :sm,
            text_color: color,
            text_align: "center",
            fill_width: true
          },
          children: []
        }
      ]
    }
  end

  defp day_label(label) do
    %{
      type: :text,
      props: %{text: label, text_size: :xs, text_color: :muted, weight: 1, text_align: "center"},
      children: []
    }
  end

  defp legend do
    %{
      type: :row,
      props: %{fill_width: true, gap: 12},
      children: [
        legend_item(:primary, I18n.t(:period)),
        legend_item(0xFFFACED9, I18n.t(:predicted)),
        legend_item(0xFFD3EFDA, I18n.t(:ovulation))
      ]
    }
  end

  defp legend_item(color, label) do
    %{
      type: :row,
      props: %{align: :center, gap: 6},
      children: [
        %{
          type: :box,
          props: %{background: color, corner_radius: :radius_sm, width: 12, height: 12},
          children: []
        },
        %{type: :text, props: %{text: label, text_size: :xs, text_color: :muted}, children: []}
      ]
    }
  end
end
