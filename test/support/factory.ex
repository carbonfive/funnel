defmodule Funnel.Factory do

  use ExMachina

  def push_webhook_bad_body_factory do
    Poison.decode!(File.read!("test/support/bad_push.json"))
  end

  def push_webhook_good_body_factory do
    Poison.decode!(File.read!("test/support/good_push.json"))
  end

  def push_webhook_master_body_factory do
    Poison.decode!(File.read!("test/support/master_push.json"))
  end

end
