defmodule Scrumpokerweb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ScrumpokerwebWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Scrumpokerweb.PubSub},
      # Start the Endpoint (http/https)
      ScrumpokerwebWeb.Endpoint,
      # Start a worker by calling: Scrumpokerweb.Worker.start_link(arg)
      # {Scrumpokerweb.Worker, arg}
      {Registry, keys: :unique, name: Scrumpoker.GameRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Scrumpoker.GameSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Scrumpokerweb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ScrumpokerwebWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
