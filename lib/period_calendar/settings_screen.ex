defmodule PeriodCalendar.SettingsScreen do
  @moduledoc "Settings: theme + language (+ quick cycle prefs)."
  use Mob.Screen
  alias PeriodCalendar.{I18n, Onboarding, Themes}
  alias PeriodCalendar.Components.Icons

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> Mob.Socket.assign(:theme, Themes.current_key())
     |> Mob.Socket.assign(:locale, I18n.get_locale())
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
            header(assigns),
            gap(20),
            section(I18n.t(:appearance), [
              row_label(I18n.t(:theme)),
              gap(8),
              theme_picker(assigns.theme)
            ]),
            gap(16),
            section(I18n.t(:language), [
              row_label(I18n.t(:language)),
              gap(8),
              lang_picker(assigns.locale)
            ]),
            gap(16),
            section(I18n.t(:cycle), [
              stepper_row(I18n.t(:cycle_length), assigns.cycle_length, :cycle_dec, :cycle_inc),
              gap(12),
              stepper_row(I18n.t(:period_length), assigns.period_length, :period_dec, :period_inc)
            ]),
            gap(16),
            section(I18n.t(:data), [
              %{
                type: :button,
                props: %{
                  text: I18n.t(:reset_onboarding),
                  background: :surface_raised,
                  text_color: :on_surface,
                  padding: :space_md,
                  fill_width: true,
                  on_tap: {self(), :reset}
                },
                children: []
              },
              notice(assigns.notice)
            ]),
            gap(24),
            back_button()
          ]
        }
      ]
    }
  end

  def handle_info({:tap, {:set_theme, key}}, socket) do
    Themes.set(key)
    {:noreply, Mob.Socket.assign(socket, :theme, key)}
  end

  def handle_info({:tap, {:set_locale, locale}}, socket) do
    I18n.set_locale(locale)
    {:noreply, Mob.Socket.assign(socket, :locale, locale)}
  end

  def handle_info({:tap, :cycle_dec}, socket),
    do: adjust(socket, :cycle_length, max(socket.assigns.cycle_length - 1, 21))

  def handle_info({:tap, :cycle_inc}, socket),
    do: adjust(socket, :cycle_length, min(socket.assigns.cycle_length + 1, 35))

  def handle_info({:tap, :period_dec}, socket),
    do: adjust(socket, :period_length, max(socket.assigns.period_length - 1, 2))

  def handle_info({:tap, :period_inc}, socket),
    do: adjust(socket, :period_length, min(socket.assigns.period_length + 1, 8))

  def handle_info({:tap, :reset}, socket) do
    Onboarding.reset()
    {:noreply, Mob.Socket.assign(socket, :notice, I18n.t(:reset_done))}
  end

  def handle_info({:tap, :back}, socket), do: {:noreply, Mob.Socket.pop_screen(socket)}
  def handle_info(_msg, socket), do: {:noreply, socket}

  defp adjust(socket, key, value) do
    cycle = if key == :cycle_length, do: value, else: socket.assigns.cycle_length
    period = if key == :period_length, do: value, else: socket.assigns.period_length
    Onboarding.complete(cycle, period)
    {:noreply, Mob.Socket.assign(socket, key, value)}
  end

  defp header(_assigns) do
    %{
      type: :row,
      props: %{fill_width: true, align: :center, gap: 8},
      children: [
        Icons.icon(:gear, :lg, :primary),
        %{
          type: :column,
          props: %{weight: 1, fill_width: true},
          children: [
            %{
              type: :text,
              props: %{
                text: I18n.t(:settings_title),
                text_size: :xl,
                text_color: :on_surface,
                font_weight: "bold",
                fill_width: true
              },
              children: []
            },
            %{
              type: :text,
              props: %{
                text: I18n.t(:settings_subtitle),
                text_size: :sm,
                text_color: :muted,
                fill_width: true
              },
              children: []
            }
          ]
        }
      ]
    }
  end

  defp section(title, children) do
    card([
      %{
        type: :text,
        props: %{text: title, text_size: :base, text_color: :on_surface, font_weight: "bold"},
        children: []
      },
      gap(10) | children
    ])
  end

  defp row_label(text),
    do: %{type: :text, props: %{text: text, text_size: :sm, text_color: :muted}, children: []}

  defp theme_picker(active) do
    %{
      type: :row,
      props: %{fill_width: true, gap: 10},
      children: [
        choice(I18n.t(:theme_light), :light, active == :light, {:set_theme, :light}),
        choice(I18n.t(:theme_dark), :dark, active == :dark, {:set_theme, :dark})
      ]
    }
  end

  defp lang_picker(active) do
    %{
      type: :row,
      props: %{fill_width: true, gap: 10},
      children: [
        choice(I18n.t(:lang_en), :en, active == :en, {:set_locale, :en}),
        choice(I18n.t(:lang_uk), :uk, active == :uk, {:set_locale, :uk})
      ]
    }
  end

  defp choice(label, _key, active?, event) do
    bg = if active?, do: :primary, else: :surface_raised
    fg = if active?, do: :on_primary, else: :on_surface

    %{
      type: :box,
      props: %{
        weight: 1,
        background: bg,
        corner_radius: :radius_md,
        padding: :space_md,
        on_tap: {self(), event}
      },
      children: [
        %{
          type: :text,
          props: %{
            text: label,
            text_size: :sm,
            text_color: fg,
            text_align: "center",
            font_weight: "bold"
          },
          children: []
        }
      ]
    }
  end

  defp stepper_row(label, value, dec, inc) do
    %{
      type: :row,
      props: %{fill_width: true, align: :center},
      children: [
        %{
          type: :text,
          props: %{text: label, text_size: :sm, text_color: :on_surface, weight: 1},
          children: []
        },
        %{
          type: :box,
          props: %{padding: 8, on_tap: {self(), dec}},
          children: [Icons.icon(:minus, :lg, :on_surface)]
        },
        %{
          type: :text,
          props: %{
            text: "#{value} #{I18n.t(:days)}",
            text_size: :base,
            text_color: :primary,
            font_weight: "bold",
            text_align: "center",
            weight: 1
          },
          children: []
        },
        %{
          type: :box,
          props: %{padding: 8, on_tap: {self(), inc}},
          children: [Icons.icon(:plus, :lg, :on_surface)]
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

  defp notice(nil), do: %{type: :spacer, props: %{size: 6}, children: []}

  defp notice(v),
    do: %{
      type: :text,
      props: %{text: v, text_size: :sm, text_color: :green_500, padding: :space_sm},
      children: []
    }

  defp gap(n), do: %{type: :spacer, props: %{size: n}, children: []}

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
end
