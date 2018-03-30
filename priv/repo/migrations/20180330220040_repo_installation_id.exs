defmodule Funnel.Repo.Migrations.RepoInstallationId do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      add :git_hub_installation_id, :bigint, null: false
    end
  end
end
