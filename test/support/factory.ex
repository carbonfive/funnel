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

  def bad_push_scent_factory do
    %Funnel.Scent{
      owner_login: "outofambit",
      repo_name: "musical-spork",
      commit_sha: "6e669ab91b9cec1ff8bfcdd00dc18a87733269b1",
      default_branch_name: "master",
      installation_id: 65943,
      ref: "refs/heads/bad-boy",
    }
  end

  def good_push_scent_factory do
    %Funnel.Scent{
      commit_sha: "6b7d4200317e2b5e2cad2b19a22e7ad8e8add382",
      default_branch_name: "master",
      installation_id: 65943,
      owner_login: "outofambit",
      ref: "refs/heads/good-boy",
      repo_name: "musical-spork"
    }
  end

  def default_push_scent_factory do
    %Funnel.Scent{
      commit_sha: "966bf60dcd5b7eb57997ae88ef2e46f6549a9c8a",
      default_branch_name: "master",
      installation_id: 65943,
      owner_login: "outofambit",
      ref: "refs/heads/master",
      repo_name: "musical-spork"
    }
  end

end
