defmodule PeriodCalendar.LockScreen do
  @moduledoc "Privacy gate for the local health data."
  use Mob.Screen
  alias PeriodCalendar.I18n

  def mount(_params, _session, socket) do
    socket = Mob.Socket.assign(socket, :status, I18n.t(:unlock_continue))
    {:ok, MobBiometric.authenticate(socket, reason: I18n.t(:unlock_continue))}
  end

  def render(assigns) do
    %{
      type: :column,
      props: %{
        background: :background,
        padding: :space_lg,
        fill_width: true,
        fill_height: true,
        align: :center
      },
      children: [
        %{type: :spacer, props: %{weight: 1}, children: []},
        %{
          type: :text,
          props: %{
            text: I18n.t(:lock_title),
            text_size: :"4xl",
            text_color: :primary,
            font_weight: "bold",
            text_align: "center"
          },
          children: []
        },
        %{
          type: :text,
          props: %{
            text: I18n.t(:lock_subtitle),
            text_size: :lg,
            text_color: :on_surface,
            text_align: "center"
          },
          children: []
        },
        %{type: :spacer, props: %{size: 12}, children: []},
        %{
          type: :text,
          props: %{text: assigns.status, text_size: :sm, text_color: :muted, text_align: "center"},
          children: []
        },
        %{type: :spacer, props: %{size: 24}, children: []},
        %{
          type: :button,
          props: %{
            text: I18n.t(:unlock_biometrics),
            background: :primary,
            text_color: :on_primary,
            padding: :space_md,
            on_tap: {self(), :unlock}
          },
          children: []
        },
        %{type: :spacer, props: %{size: 12}, children: []},
        %{
          type: :button,
          props: %{
            text: I18n.t(:continue_sim),
            background: :surface_raised,
            text_color: :on_surface,
            padding: :space_sm,
            on_tap: {self(), :skip}
          },
          children: []
        },
        %{type: :spacer, props: %{weight: 1}, children: []}
      ]
    }
  end

  def handle_info({:tap, :unlock}, socket),
    do: {:noreply, MobBiometric.authenticate(socket, reason: I18n.t(:unlock_continue))}

  def handle_info({:biometric, :success}, socket),
    do: {:noreply, push_next(socket)}

  def handle_info({:biometric, :failure}, socket),
    do: {:noreply, Mob.Socket.assign(socket, :status, I18n.t(:unlock_cancelled))}

  def handle_info({:biometric, :not_available}, socket),
    do: {:noreply, Mob.Socket.assign(socket, :status, I18n.t(:no_biometrics))}

  def handle_info({:tap, :skip}, socket),
    do: {:noreply, push_next(socket)}

  def handle_info(_message, socket), do: {:noreply, socket}

  defp push_next(socket) do
    if PeriodCalendar.Onboarding.onboarded?() do
      Mob.Socket.push_screen(socket, PeriodCalendar.HomeScreen)
    else
      Mob.Socket.push_screen(socket, PeriodCalendar.OnboardingScreen)
    end
  end
end
