defmodule PeriodCalendar.LogScreen do
  @moduledoc "Quick flow logging entry point."
  use Mob.Screen
  alias PeriodCalendar.{Cycle, I18n}

  def mount(_params, _session, socket), do: {:ok, Mob.Socket.assign(socket, :saved, nil)}

  def render(assigns) do
    flows = [
      {I18n.t(:flow_light), "light"},
      {I18n.t(:flow_medium), "medium"},
      {I18n.t(:flow_heavy), "heavy"}
    ]

    %{
      type: :scroll,
      props: %{background: :background, fill_width: true, fill_height: true},
      children: [
        %{
          type: :column,
          props: %{padding: :space_lg, fill_width: true},
          children: [
            text(I18n.t(:log_today), :"2xl", :on_surface, "bold"),
            text(I18n.t(:log_today_desc), :sm, :muted),
            gap(24),
            text(I18n.t(:flow), :lg, :on_surface, "bold"),
            gap(10),
            %{
              type: :column,
              props: %{fill_width: true},
              children: Enum.map(flows, &flow_button/1)
            },
            saved_notice(assigns.saved),
            gap(30),
            back_button()
          ]
        }
      ]
    }
  end

  def handle_info({:tap, {:flow, flow}}, socket) do
    Cycle.log_period_start(Date.utc_today(), flow)
    {:noreply, Mob.Socket.assign(socket, :saved, I18n.t(:saved_privately))}
  end

  def handle_info({:tap, :back}, socket), do: {:noreply, Mob.Socket.pop_screen(socket)}
  def handle_info(_message, socket), do: {:noreply, socket}

  defp flow_button({label, value}) do
    %{
      type: :button,
      props: %{
        text: label,
        background: :surface,
        text_color: :on_surface,
        padding: :space_md,
        fill_width: true,
        on_tap: {self(), {:flow, value}}
      },
      children: []
    }
  end

  defp saved_notice(nil), do: %{type: :spacer, props: %{size: 24}, children: []}

  defp saved_notice(value),
    do: %{
      type: :text,
      props: %{text: value, text_size: :sm, text_color: :green_500, padding: :space_md},
      children: []
    }

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

  defp gap(size), do: %{type: :spacer, props: %{size: size}, children: []}
end
