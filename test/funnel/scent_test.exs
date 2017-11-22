defmodule Funnel.ScentTest do
  use ExUnit.Case, async: true
  import Funnel.Factory
  alias Funnel.Scent

  test "get_scent/1" do
    scent = Scent.get_scent build(:push_webhook_bad_body)
    assert scent == %Funnel.Scent{
      owner_login: "outofambit",
      repo_name: "musical-spork",
      commit_sha: "6e669ab91b9cec1ff8bfcdd00dc18a87733269b1",
      default_branch_name: "master",
      installation_id: 65943,
      ref: "refs/heads/bad-boy",
    }
  end

end
