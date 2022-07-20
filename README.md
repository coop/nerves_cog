# NervesCog

Launch Cog inside a running weston instance.

This project works very well with
[nerves_weston](https://github.com/coop/nerves_weston) but should work equally
well with a different wayland compositor.

NOTE: The current implementation assumes you are wanting to run cog using a
wayland compositor. Although cog allows swapping backends that functionality is
not exposed today.

## Usage

```elixir
{NervesCog, url: "http://localhost:4000", xdg_runtime_dir: "/tmp/nerves_weston", wayland_display: "wayland-1", name: :cog}
```

## Installation

Include `nerves_cog` in your dependencies referencing `github`:

```elixir
def deps do
  [
    {:nerves_cog, github: "coop/nerves_cog"}
  ]
end
```
