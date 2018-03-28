defmodule Funnel.Repo.Migrations.AddRepositoryDetails do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      add :details, :map
    end
  end
end
