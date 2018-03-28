defmodule Funnel.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add :git_hub_id, :integer, null: false
      add :strategy_id, references(:strategies)
      timestamps()
    end

    create unique_index(:repositories, :git_hub_id)

  end
end
