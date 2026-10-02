defmodule PeriodCalendar.OnboardingScreen do
  @moduledoc "First-run setup: how long period lasts and typical cycle length."
  use Mob.Screen

  alias PeriodCalendar.{I18n, Onboarding}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> Mob.Socket.assign(:cycle_length, Onboarding.cycle_length())
     |> Mob.Socket.assign(:period_length, Onboarding.period_length())
     |> Mob.Socket.assign(:notice, nil)}
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
            gap(12),
            text(I18n.t(:onboarding_title), :"2xl", :on_surface, "bold"),
            gap(6),
            text(I18n.t(:onboarding_subtitle), :sm, :muted),
            gap(20),
            card([
              text(I18n.t(:typical_cycle), :base, :on_surface, "bold"),
              gap(4),
              text(I18n.t(:typical_cycle_desc), :sm, :muted),
              gap(14),
              stepper(assigns.cycle_length, :cycle_dec, :cycle_inc, I18n.t(:days))
            ]),
            gap(14),
            card([
              text(I18n.t(:typical_period), :base, :on_surface, "bold"),
              gap(4),
              text(I18n.t(:typical_period_desc), :sm, :muted),
              gap(14),
              stepper(assigns.period_length, :period_dec, :period_inc, I18n.t(:days))
            ]),
            gap(20),
            %{
              type: :button,
              props: %{
                text: I18n.t(:continue),
                background: :primary,
                text_color: :on_primary,
                padding: :space_md,
                fill_width: true,
                on_tap: {self(), :save}
              },
              children: []
            },
            notice(assigns.notice),
            gap(10),
            text(I18n.t(:estimates_note), :xs, :muted)
          ]
        }
      ]
    }
  end

  def handle_info({:tap, :cycle_dec}, socket) do
    {:noreply, Mob.Socket.assign(socket, :cycle_length, max(socket.assigns.cycle_length - 1, 21))}
  end

  def handle_info({:tap, :cycle_inc}, socket) do
    {:noreply, Mob.Socket.assign(socket, :cycle_length, min(socket.assigns.cycle_length + 1, 35))}
  end

  def handle_info({:tap, :period_dec}, socket) do
    {:noreply,
     Mob.Socket.assign(socket, :period_length, max(socket.assigns.period_length - 1, 2))}
  end

  def handle_info({:tap, :period_inc}, socket) do
    {:noreply,
     Mob.Socket.assign(socket, :period_length, min(socket.assigns.period_length + 1, 8))}
  end

  def handle_info({:tap, :save}, socket) do
    Onboarding.complete(socket.assigns.cycle_length, socket.assigns.period_length)

    {:noreply,
     socket
     |> Mob.Socket.assign(:notice, I18n.t(:saved))
     |> Mob.Socket.push_screen(PeriodCalendar.HomeScreen)}
  end

  def handle_info(_message, socket), do: {:noreply, socket}

  defp stepper(value, dec_event, inc_event, suffix) do
    %{
      type: :row,
      props: %{fill_width: true, align: :center},
      children: [
        %{
          type: :button,
          props: %{
            text: "−",
            background: :surface_raised,
            text_color: :on_surface,
            padding: :space_md,
            on_tap: {self(), dec_event}
          },
          children: []
        },
        %{type: :spacer, props: %{weight: 1}, children: []},
        %{
          type: :column,
          props: %{align: :center},
          children: [
            %{
              type: :text,
              props: %{
                text: Integer.to_string(value),
                text_size: :"3xl",
                text_color: :primary,
                font_weight: "bold",
                text_align: "center"
              },
              children: []
            },
            %{
              type: :text,
              props: %{text: suffix, text_size: :xs, text_color: :muted, text_align: "center"},
              children: []
            }
          ]
        },
        %{type: :spacer, props: %{weight: 1}, children: []},
        %{
          type: :button,
          props: %{
            text: "+",
            background: :surface_raised,
            text_color: :on_surface,
            padding: :space_md,
            on_tap: {self(), inc_event}
          },
          children: []
        }
      ]
    }
  end

  defp card(children) do
    %{
      type: :box,
      props: %{
        background: :surface,
        corner_radius: :radius_lg,
        padding: :space_lg,
        fill_width: true
      },
      children: [%{type: :column, props: %{fill_width: true}, children: children}]
    }
  end

  defp text(value, size, color, weight \\ nil) do
    props = %{text: value, text_size: size, text_color: color}
    props = if weight, do: Map.put(props, :font_weight, weight), else: props
    %{type: :text, props: props, children: []}
  end

  defp notice(nil), do: %{type: :spacer, props: %{size: 8}, children: []}

  defp notice(value) do
    %{
      type: :text,
      props: %{
        text: value,
        text_size: :sm,
        text_color: :green_500,
        padding: :space_sm,
        text_align: "center"
      },
      children: []
    }
  end

  defp gap(size), do: %{type: :spacer, props: %{size: size}, children: []}
end
