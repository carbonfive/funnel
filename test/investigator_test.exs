defmodule Funnel.InvestigatorTest do
  use ExUnit.Case

  test "call with push request and doesn't error out" do
    Funnel.Investigator.investigate Funnel.Factory.build(:push_webhook_body)
  end

end
