defmodule Funnel.GitHub.Repository do
  use Ecto.Schema
  import Ecto.Changeset
  alias Funnel.GitHub.Repository


  schema "repositories" do
    field :git_hub_id, :integer, nil: false
    field :git_hub_installation_id, :integer, nil: false
    belongs_to :strategy, Funnel.Git.Strategy
    embeds_one :details, Funnel.GitHub.RepositoryDetails, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(%Repository{} = repository, attrs) do
    repository
    |> cast(attrs, [:git_hub_id, :git_hub_installation_id, :strategy_id])
    |> cast_embed(:details)
    |> foreign_key_constraint(:strategy_id)
    |> unique_constraint(:git_hub_id)
    |> validate_required(:git_hub_id)
  end
end
