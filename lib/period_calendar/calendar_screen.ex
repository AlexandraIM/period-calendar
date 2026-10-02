defmodule PeriodCalendar.CalendarScreen do
  @moduledoc "Monthly local cycle calendar."
  use Mob.Screen
  alias PeriodCalendar.{Cycle, I18n}
  alias PeriodCalendar.Components.Calendar, as: Cal
  alias PeriodCalendar.Components.Icons

  def mount(_params, _session, socket) do
    month = Date.beginning_of_month(Date.utc_today())

    {:ok,
     Mob.Socket.assign(socket,
       month: month,
       periods: Cycle.period_dates(),
       predictions: Cycle.predicted_period_dates(month),
       ovulations: Cycle.predicted_ovulation_dates(month)
     )}
  end

  def render(assigns) do
    %{
      type: :scroll,
      props: %{background: :background, fill_width: true, fill_height: true},
      children: [
        %{
          type: :column,
          props: %{padding: :space_lg, fill_width: true},
          children: [
            month_nav(assigns.month),
            text(I18n.t(:calendar_subtitle), :sm, :muted),
            gap(20),
            Cal.month_grid(
              assigns.month,
              assigns.periods,
              assigns.predictions,
              assigns.ovulations
            ),
            gap(30),
            back_button()
          ]
        }
      ]
    }
  end

  def handle_info({:tap, :prev}, socket) do
    new_month = shift_month(socket.assigns.month, -1)

    {:noreply,
     Mob.Socket.assign(socket,
       month: new_month,
       predictions: Cycle.predicted_period_dates(new_month),
       ovulations: Cycle.predicted_ovulation_dates(new_month)
     )}
  end

  def handle_info({:tap, :next}, socket) do
    new_month = shift_month(socket.assigns.month, 1)

    {:noreply,
     Mob.Socket.assign(socket,
       month: new_month,
       predictions: Cycle.predicted_period_dates(new_month),
       ovulations: Cycle.predicted_ovulation_dates(new_month)
     )}
  end

  def handle_info({:tap, :back}, socket), do: {:noreply, Mob.Socket.pop_screen(socket)}
  def handle_info(_message, socket), do: {:noreply, socket}

  defp month_nav(month) do
    %{
      type: :row,
      props: %{fill_width: true, align: :center},
      children: [
        %{
          type: :box,
          props: %{weight: 1, align: :center, padding: 4, on_tap: {self(), :prev}},
          children: [Icons.icon(:caret_left, :lg, :on_surface)]
        },
        %{
          type: :row,
          props: %{weight: 2, align: :center},
          children: [
            Icons.icon(:calendar, :sm, :muted),
            %{type: :spacer, props: %{size: 6}, children: []},
            %{
              type: :text,
              props: %{
                text: month_label(month),
                text_size: :lg,
                text_color: :on_surface,
                font_weight: "bold",
                text_align: "center",
                fill_width: true,
                max_lines: 1,
                weight: 1
              },
              children: []
            }
          ]
        },
        %{
          type: :box,
          props: %{weight: 1, align: :center, padding: 4, on_tap: {self(), :next}},
          children: [Icons.icon(:caret_right, :lg, :on_surface)]
        }
      ]
    }
  end

  defp back_button,
    do: %{
      type: :button,
      props: %{
        text: I18n.t(:back),
        background: :surface_raised,
        text_color: :on_surface,
        on_tap: {self(), :back}
      },
      children: []
    }

  defp text(value, size, color, weight \\ nil) do
    props = %{text: value, text_size: size, text_color: color}
    props = if weight, do: Map.put(props, :font_weight, weight), else: props
    %{type: :text, props: props, children: []}
  end

  defp shift_month(%Date{year: y, month: m}, delta) do
    total = y * 12 + (m - 1) + delta
    new_y = div(total, 12)
    new_m = rem(total, 12) + 1
    Date.new!(new_y, new_m, 1)
  end

  defp gap(size), do: %{type: :spacer, props: %{size: size}, children: []}
  defp month_label(date), do: Calendar.strftime(date, "%B %Y")
end
