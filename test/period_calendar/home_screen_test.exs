defmodule PeriodCalendar.HomeScreenTest do
  use Mob.ScreenCase, async: false

  alias PeriodCalendar.HomeScreen

  setup do
    PeriodCalendar.Repo.delete_all(PeriodCalendar.PeriodEntry)
    :ok
  end

  test "renders the private Today experience" do
    view = mount_screen(HomeScreen)
    rendered = tree(view)

    assert_renderable(rendered, extra: [:canvas])
    text = String.downcase(text(rendered))
    assert text =~ "your cycle starts here"
    assert text =~ "your data stays here"
    assert text =~ "no tracking"
  end

  test "logs today's period start locally" do
    view = mount_screen(HomeScreen)
    view = render_info(view, {:tap, :log_period})

    assert assigns(view).logged_today
    assert PeriodCalendar.Cycle.logged_today?()
    assert text(tree(view)) =~ "Period logged today"
  end

  test "does not create a duplicate entry for today" do
    view = mount_screen(HomeScreen) |> render_info({:tap, :log_period})
    view = render_info(view, {:tap, :log_period})

    assert assigns(view).notice == "Already logged for today"
    assert length(PeriodCalendar.Repo.all(PeriodCalendar.PeriodEntry)) == 1
  end
end
