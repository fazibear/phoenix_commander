defmodule PhoenixCommander.Browser do
  use GenServer
  alias WebengineKiosk.Options

  @args [homepage: "http://localhost:41234", fullscreen: false]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(_args) do
    priv_dir = :code.priv_dir(:webengine_kiosk)
    cmd = Path.join(priv_dir, "kiosk")

    if !File.exists?(cmd) do
      raise "Kiosk port missing"
    end

    all_options = Options.add_defaults(@args)

    cmd_args =
      all_options
      |> Enum.flat_map(fn {key, value} -> ["--#{key}", to_string(value)] end)

    # WebengineKiosk.set_permissions(all_options)
    homepage = Keyword.get(all_options, :homepage)

    port =
      Port.open({:spawn_executable, cmd}, [
        {:args, cmd_args},
        {:cd, priv_dir},
        {:packet, 2},
        :use_stdio,
        :binary,
        :exit_status
      ])

    {:ok, %{port: port, homepage: homepage}}
  end

  @impl true
  def handle_info({_, {:data, _}}, state), do: {:noreply, state}

  @impl true
  def handle_info({_, {:exit_status, status}}, state) do
    System.halt(status)
    {:noreply, state}
  end
end
