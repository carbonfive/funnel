defmodule Funnel.Investigator.Status do
  @moduledoc """
  Helper functions for creating commit statuses 
  """

  def pending do
    %{
       "state": "pending",
       "description": "Investigating your branch",
       "context": "funnel"
     }
  end

  def success do
    %{
       "state": "success",
       "description": "Branch is ready for merge",
       "context": "funnel"
     }
  end

  def failure do
    %{
       "state": "failure",
       "description": "Branch must be rebased and squashed",
       "context": "funnel"
     }
  end

end
