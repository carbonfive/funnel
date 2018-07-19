defmodule Funnel.ScentTest do
  use ExUnit.Case, async: true
  import Funnel.Factory
  alias Funnel.Scent

  test "get_scent push" do
    scent = Scent.get_scent(build(:push_webhook_bad_body), "push")

    assert scent == %Funnel.Scent{
             action: nil,
             type: :push,
             owner_login: "outofambit",
             repo_name: "musical-spork",
             commit_sha: "6e669ab91b9cec1ff8bfcdd00dc18a87733269b1",
             default_branch_name: "master",
             installation_id: 65943,
             branch_name: "bad-boy",
             repo_id: 103_584_391
           }
  end

  test "get_scent pull_request" do
    scent = Scent.get_scent(build(:pull_request_webhook_payload), "pull_request")

    assert scent == %Funnel.Scent{
             action: "synchronize",
             type: :pull_request,
             branch_name: "spooon",
             commit_sha: "f09a3e8241f2f9983407de3d4cbd30ef73678ddd",
             default_branch_name: "master",
             installation_id: 66216,
             owner_login: "outofambit",
             repo_name: "musical-spork",
             pr_number: 12,
             repo_id: 103_584_391
           }
  end
end
