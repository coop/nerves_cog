defmodule NervesCog do
  use Supervisor

  def start_link(opts) do
    name = opts[:name] || raise ArgumentError, "the :name option is required"
    opts[:url] || raise ArgumentError, "the :url option is required"
    opts[:wayland_display] || raise ArgumentError, "the :wayland_display option is required"
    opts[:xdg_runtime_dir] || raise ArgumentError, "the :xdg_runtime_dir option is required"

    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  @impl Supervisor
  def init(opts) do
    env = [
      {"XDG_RUNTIME_DIR", opts[:xdg_runtime_dir]},
      {"WAYLAND_DISPLAY", opts[:wayland_display]},
      {"COG_PLATFORM_WL_VIEW_FULLSCREEN", bool_arg(opts[:fullscreen])}
    ]

    children = [
      {MuonTrap.Daemon, ["cog", ["--platform=wl", opts[:url]], [env: env]]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp bool_arg(value) when value in [1, "1", true], do: "1"
  defp bool_arg(_other), do: "0"
end
