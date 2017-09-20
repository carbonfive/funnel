defmodule Funnel.Factory do

  use ExMachina

  def push_webhook_body_factory do
    Poison.decode!(File.read!("test/support/push_webhook_body.json"))
  end

end
