defmodule Funnel.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add :git_hub_id, :integer, null: false
      timestamps()
    end

    create unique_index(:repositories, :git_hub_id)

    create table(:repositories_strategies) do
      add :repository_id, references(:repositories)
      add :strategy_id, references(:strategies)
    end

    create unique_index(:repositories_strategies, [:repository_id, :strategy_id])

  end
end
