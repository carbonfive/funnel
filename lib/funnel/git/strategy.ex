defmodule Funnel.Git.Strategy do
  use Ecto.Schema
  import Ecto.Changeset
  alias Funnel.Git.Strategy

  schema "strategies" do
    field(:description, :string)
    field(:name, :string)
    has_many(:repositories, Funnel.GitHub.Repository)

    timestamps()
  end

  @doc false
  def changeset(%Strategy{} = strategy, attrs) do
    strategy
    |> cast(attrs, [:name, :description])
    |> unique_constraint(:name)
    |> validate_required([:name])
  end
end
