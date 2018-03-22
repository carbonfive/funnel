defmodule Funnel.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add :git_hub_id, :integer, null: false
      timestamps()
    end

    create unique_index(:repositories, :git_hub_id)

    create table(:repositories_strategies, primary_key: false) do
      add :repository_id, references(:repositories), null: false
      add :strategy_id, references(:strategies), null: false
    end

    create unique_index(:repositories_strategies, [:repository_id, :strategy_id])

  end
end
