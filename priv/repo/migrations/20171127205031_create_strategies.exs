defmodule Funnel.Repo.Migrations.CreateStrategies do
  use Ecto.Migration

  def change do
    create table(:strategies) do
      add :name, :string, null: false
      add :description, :text

      timestamps()
    end

    create unique_index(:strategies, [:name])

  end
end
