defmodule Funnel.InvestigatorTest do
  use ExUnit.Case, async: false
  import Funnel.Factory
  import Mock

  setup_with_mocks([
    {Tentacat.Client, [], [
      new: fn(_auth) -> build(:tentacat_client) end
    ]},
    {Tentacat.Repositories.Statuses, [], [
      create: fn(_, _, _, _, _) -> nil end
    ]},
  ]) do
    {:ok, %{}}
  end

  test "call with push request and doesn't error out" do
    Funnel.Investigator.investigate build(:push_webhook_body)
  end

end
