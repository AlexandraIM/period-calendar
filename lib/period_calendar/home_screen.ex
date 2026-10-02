defmodule PeriodCalendar.HomeScreen do
  @moduledoc "The local-first Today screen."
  use Mob.Screen
  alias PeriodCalendar.{Cycle, I18n}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> Mob.Socket.assign(:today, Date.utc_today())
     |> Mob.Socket.assign(:latest_period, Cycle.latest_period())
     |> Mob.Socket.assign(:logged_today, Cycle.logged_today?())
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
            header(),
            gap(24),
            cycle_card(assigns),
            gap(16),
            log_card(assigns),
            gap(16),
            privacy_card(assigns),
            gap(24),
            navigation_hint()
          ]
        }
      ]
    }
  end

  def handle_info({:tap, :log_period}, %{assigns: %{logged_today: true}} = socket),
    do: {:noreply, Mob.Socket.assign(socket, :notice, I18n.t(:already_logged))}

  def handle_info({:tap, :log_period}, socket) do
    Cycle.log_period_start(socket.assigns.today)

    {:noreply,
     socket
     |> Mob.Socket.assign(:latest_period, Cycle.latest_period())
     |> Mob.Socket.assign(:logged_today, true)
     |> Mob.Socket.assign(:notice, I18n.t(:saved))}
  end

  def handle_info({:tap, :clear_notice}, socket),
    do: {:noreply, Mob.Socket.assign(socket, :notice, nil)}

  def handle_info({:tap, :open_calendar}, socket),
    do: {:noreply, Mob.Socket.push_screen(socket, PeriodCalendar.CalendarScreen)}

  def handle_info({:tap, :open_log}, socket),
    do: {:noreply, Mob.Socket.push_screen(socket, PeriodCalendar.LogScreen)}

  def handle_info({:tap, :open_settings}, socket),
    do: {:noreply, Mob.Socket.push_screen(socket, PeriodCalendar.SettingsScreen)}

  def handle_info(_message, socket), do: {:noreply, socket}

  defp header do
    %{
      type: :column,
      props: %{fill_width: true},
      children: [
        %{
          type: :row,
          props: %{fill_width: true, align: :center},
          children: [
            text(I18n.t(:lock_title), :xl, :on_surface),
            %{type: :spacer, props: %{weight: 1}, children: []},
            text(I18n.t(:private_badge), :xs, :green_500)
          ]
        },
        text(I18n.t(:gentle_view), :sm, :muted)
      ]
    }
  end

  defp cycle_card(%{latest_period: nil}) do
    card([
      text(I18n.t(:cycle_starts_here), :lg, :on_surface, "bold"),
      gap(8),
      text(I18n.t(:cycle_starts_desc), :sm, :muted)
    ])
  end

  defp cycle_card(%{latest_period: period, today: today}) do
    day = Date.diff(today, period.date) + 1

    card([
      text(I18n.t(:current_cycle), :sm, :muted),
      gap(4),
      text("#{I18n.t(:day)} #{day}", :"4xl", :primary, "bold"),
      gap(4),
      text("#{I18n.t(:started)} #{Date.to_iso8601(period.date)}", :sm, :muted)
    ])
  end

  defp log_card(%{logged_today: logged}) do
    label = if logged, do: I18n.t(:period_logged_today), else: I18n.t(:did_period_start)
    button = if logged, do: I18n.t(:logged), else: I18n.t(:log_period_start)

    card([
      text(label, :lg, :on_surface, "bold"),
      gap(12),
      %{
        type: :button,
        props: %{
          text: button,
          background: :primary,
          text_color: :on_primary,
          padding: :space_md,
          fill_width: true,
          disabled: logged,
          on_tap: {self(), :log_period}
        },
        children: []
      }
    ])
  end

  defp privacy_card(assigns) do
    notice =
      case assigns.notice do
        nil ->
          []

        value ->
          [
            gap(10),
            %{
              type: :text,
              props: %{
                text: value,
                text_size: :sm,
                text_color: :green_500,
                on_tap: {self(), :clear_notice}
              },
              children: []
            }
          ]
      end

    card(
      [
        text(I18n.t(:your_data_stays), :base, :on_surface, "bold"),
        gap(6),
        text(I18n.t(:no_account), :sm, :muted)
      ] ++ notice,
      :surface_raised
    )
  end

  defp navigation_hint do
    %{
      type: :column,
      props: %{fill_width: true},
      children: [
        %{
          type: :row,
          props: %{fill_width: true, align: :center},
          children: [
            nav_button(I18n.t(:today)),
            %{type: :spacer, props: %{weight: 1}, children: []},
            nav_button(I18n.t(:calendar), :open_calendar),
            %{type: :spacer, props: %{size: 10}, children: []},
            nav_button(I18n.t(:log), :open_log)
          ]
        },
        gap(10),
        %{
          type: :button,
          props: %{
            text: I18n.t(:settings),
            background: :surface_raised,
            text_color: :on_surface,
            text_size: :sm,
            padding: :space_sm,
            fill_width: true,
            on_tap: {self(), :open_settings}
          },
          children: []
        }
      ]
    }
  end

  defp nav_button(label), do: text(label, :sm, :primary, "bold")

  defp nav_button(label, event) do
    %{
      type: :button,
      props: %{
        text: label,
        background: :surface_raised,
        text_color: :on_surface,
        text_size: :sm,
        padding: :space_sm,
        on_tap: {self(), event}
      },
      children: []
    }
  end

  defp card(children, background \\ :surface) do
    %{
      type: :box,
      props: %{
        background: background,
        corner_radius: :radius_lg,
        padding: :space_lg,
        fill_width: true
      },
      children: [
        %{
          type: :column,
          props: %{fill_width: true},
          children: children
        }
      ]
    }
  end

  defp text(value, size, color, weight \\ nil) do
    props = %{text: value, text_size: size, text_color: color}
    props = if weight, do: Map.put(props, :font_weight, weight), else: props
    %{type: :text, props: props, children: []}
  end

  defp gap(size), do: %{type: :spacer, props: %{size: size}, children: []}
end
