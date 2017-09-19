defmodule Funnel do
  @moduledoc """
  Documentation for Funnel.
  """
  use Application
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(Funnel.Router, [])
    ]
    opts = [
      strategy: :one_for_one, name: Funnel.Supervisor
    ]
    Supervisor.start_link(children, opts)
  end
  @doc """
  Hello world.

  ## Examples

      iex> Funnel.hello
      :world

  """
  def hello do
    :world
  end
end
