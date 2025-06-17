defmodule Reldash.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ReldashWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:reldash, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Reldash.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Reldash.Finch},
      # Start a worker by calling: Reldash.Worker.start_link(arg)
      # {Reldash.Worker, arg},
      # Start to serve requests, typically the last entry
      ReldashWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Reldash.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ReldashWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
