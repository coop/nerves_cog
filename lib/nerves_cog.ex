defmodule NervesCog do
  use Supervisor

  @default_cli_args ["--platform=wl"]
  @webkit_inspector_host "0.0.0.0"
  @webkit_inspector_port 9222

  @definition [
    name: [
      required: true,
      type: :atom
    ],
    url: [
      required: true,
      type: :string
    ],
    xdg_runtime_dir: [
      required: true,
      type: :string
    ],
    wayland_display: [
      required: true,
      type: :string
    ],
    cli_args: [
      required: false,
      type: {:list, :string},
      default: []
    ],
    webkit_inspector: [
      required: false,
      type:
        {:or,
         [
           :boolean,
           {:keyword_list,
            [
              host: [required: false, type: :string, default: @webkit_inspector_host],
              port: [required: false, type: :pos_integer, default: @webkit_inspector_port]
            ]}
         ]},
      default: false
    ],
    fullscreen: [
      type: :boolean,
      required: false
    ],
    maximize: [
      type: :boolean,
      required: false
    ],
    width: [
      type: :pos_integer,
      required: false
    ],
    height: [
      type: :pos_integer,
      required: false
    ],
    daemon_opts: [
      type: :keyword_list,
      required: false,
      default: []
    ]
  ]
  @schema NimbleOptions.new!(@definition)

  def start_link(opts) do
    opts =
      opts
      |> NimbleOptions.validate!(@schema)
      |> update_in([:webkit_inspector], fn
        true -> [host: @webkit_inspector_host, port: @webkit_inspector_port]
        other -> other
      end)

    Supervisor.start_link(__MODULE__, opts, name: opts[:name])
  end

  @impl Supervisor
  def init(opts) do
    args = @default_cli_args ++ args_from_opts(opts) ++ [opts[:url]]
    env = env_vars_from_opts(opts)

    children = [
      {MuonTrap.Daemon, ["cog", args, [{:env, env} | opts[:daemon_opts]]]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp args_from_opts(opts) do
    Enum.flat_map(opts, fn
      {:cli_args, args} -> args
      {:webkit_inspector, opts} when is_list(opts) -> ["--enable-developer-extras=1"]
      _other -> []
    end)
  end

  # https://github.com/Igalia/cog/blob/master/docs/platform-wl.md#environment-variables
  defp env_vars_from_opts(opts) do
    opts
    |> Enum.map(fn
      {:xdg_runtime_dir, value} ->
        {"XDG_RUNTIME_DIR", value}

      {:wayland_display, value} ->
        {"WAYLAND_DISPLAY", value}

      {:fullscreen, value} ->
        {"COG_PLATFORM_WL_VIEW_FULLSCREEN", bool_arg(value)}

      {:maximize, value} ->
        {"COG_PLATFORM_WL_VIEW_MAXIMIZE", bool_arg(value)}

      {:width, value} ->
        {"COG_PLATFORM_WL_VIEW_WIDTH", to_string(value)}

      {:height, value} ->
        {"COG_PLATFORM_WL_VIEW_HEIGHT", to_string(value)}

      {:webkit_inspector, opts} when is_list(opts) ->
        {"WEBKIT_INSPECTOR_SERVER", "#{opts[:host]}:#{opts[:port]}"}

      _other ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp bool_arg(value) when value in [1, "1", true], do: "1"
  defp bool_arg(_other), do: "0"
end
