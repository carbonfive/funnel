defmodule Funnel.GitHub.Repository do
  use Ecto.Schema
  import Ecto.Changeset
  alias Funnel.GitHub.Repository


  schema "repositories" do
    field :git_hub_id, :integer, nil: false
    many_to_many :strategy, Funnel.Git.Strategy, join_through: "repositories_strategies"

    timestamps()
  end

  @doc false
  def changeset(%Repository{} = repository, attrs) do
    repository
    |> cast(attrs, [:git_hub_id])
    |> unique_constraint(:git_hub_id)
    |> validate_required([:git_hub_id])
  end
end
