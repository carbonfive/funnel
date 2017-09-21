defmodule Funnel.Factory do

  use ExMachina

  def tentacat_client_factory do
    %Tentacat.Client{auth: nil, endpoint: "https://api.github.com/"}
  end

  def push_webhook_body_factory do
    Poison.decode!(File.read!("test/support/push_webhook_body.json"))
  end

end
