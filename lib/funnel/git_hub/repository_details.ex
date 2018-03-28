defmodule Funnel.GitHub.RepositoryDetails do
  use Ecto.Schema
  import Ecto.Changeset
  alias Funnel.GitHub.RepositoryDetails

  embedded_schema do
    field :name, :string
    field :owner, :string
  end

  @doc false
  def changeset(%RepositoryDetails{} = repository_details, attrs) do
    repository_details
    |> cast(attrs, [:owner, :name])
    |> validate_required([:owner, :name])
  end
end
