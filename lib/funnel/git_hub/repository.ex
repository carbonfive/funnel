defmodule Funnel.GitHub.Repository do
  use Ecto.Schema
  import Ecto.Changeset
  alias Funnel.GitHub.Repository


  schema "repositories" do
    field :git_hub_id, :integer, nil: false
    many_to_many :strategy, Funnel.Git.Strategy, join_through: "repositories_strategies"
    embeds_one :details, Funnel.GitHub.RepositoryDetails, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(%Repository{} = repository, attrs) do
    repository
    |> cast(attrs, [:git_hub_id])
    |> cast_embed(:details)
    |> unique_constraint(:git_hub_id)
    |> validate_required(:git_hub_id)
  end
end
