defmodule Funnel.Investigator.Status do
  @moduledoc """
  Helper functions for creating commit statuses
  """

  @spec pending() :: map
  def pending do
    %{
       "state": "pending",
       "description": "Investigating your branch",
       "context": "funnel"
     }
  end

  @spec pending_strategy() :: map
  def pending_strategy do
    %{
       "state": "pending",
       "description": "No strategy is configured for this repository",
       "context": "funnel"
     }
  end

  @spec success() :: map
  def success do
    %{
       "state": "success",
       "description": "Branch is ready for merge",
       "context": "funnel"
     }
  end

  @spec failure(binary) :: map
  def failure(message \\ "Branch must be updated according to strategy") do
    %{
       "state": "failure",
       "description": message,
       "context": "funnel"
     }
  end

end
