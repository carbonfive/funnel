defmodule Funnel.InvestigatorTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Funnel.Factory

  setup_all do
    HTTPoison.start
  end

  test "bad non default branch pushed" do
    use_cassette "bad_non_default_branch_pushed" do
      Funnel.Investigator.investigate build(:push_webhook_body)
    end
  end

end
