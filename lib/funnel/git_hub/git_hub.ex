defmodule Funnel.GitHub do
  @moduledoc """
  The GitHub context.
  """

  import Ecto.Query, warn: false
  alias Funnel.Repo

  alias Funnel.GitHub.Repository
  alias Funnel.Git

  @doc """
  Returns the list of repositories.

  ## Examples

      iex> list_repositories()
      [%Repository{}, ...]

  """
  def list_repositories do
    Repo.all(Repository)
  end

  @doc """
  Gets a single repository.

  Raises `Ecto.NoResultsError` if the Repository does not exist.

  ## Examples

      iex> get_repository!(123)
      %Repository{}

      iex> get_repository!(456)
      ** (Ecto.NoResultsError)

  """
  def get_repository!(id), do: Repo.get!(Repository, id)

  @doc """
  Gets or creates a single repository with the given GitHub ID.

  ## Examples

      iex> get_or_create_repository_with_git_hub_id(123)
      %Repository{git_hub_id: 123}

  """
  @spec get_or_create_repository_with_git_hub_id(integer, map) :: %Repository{}
  def get_or_create_repository_with_git_hub_id(git_hub_id, attrs \\ %{}) do
    case Repo.get_by(Repository, git_hub_id: git_hub_id) do
      nil ->
        create_repository(Map.merge(attrs, %{git_hub_id: git_hub_id}))
        # this `elem` is probably bad—-we should do better error handling
        |> elem(1)
      repository ->
        repository
    end
  end

  @doc """
  Creates a repository.

  ## Examples

      iex> create_repository(%{field: value})
      {:ok, %Repository{}}

      iex> create_repository(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_repository(attrs \\ %{}) do
    %Repository{}
    |> Repository.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a repository.

  ## Examples

      iex> update_repository(repository, %{field: new_value})
      {:ok, %Repository{}}

      iex> update_repository(repository, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_repository(%Repository{} = repository, attrs) do
    repository
    |> Repository.changeset(attrs)
    |> Repo.update()
  end

  @spec update_repository_strategy(%Repository{}, %Git.Strategy{}) :: %Repository{}
  def update_repository_strategy(repository, strategy) do
    repository
    |> Repository.changeset(%{})
    |> Ecto.Changeset.put_assoc(:strategies, [strategy])
    |> Repo.update()
  end

  @doc """
  Deletes a Repository.

  ## Examples

      iex> delete_repository(repository)
      {:ok, %Repository{}}

      iex> delete_repository(repository)
      {:error, %Ecto.Changeset{}}

  """
  def delete_repository(%Repository{} = repository) do
    Repo.delete(repository)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking repository changes.

  ## Examples

      iex> change_repository(repository)
      %Ecto.Changeset{source: %Repository{}}

  """
  def change_repository(%Repository{} = repository) do
    Repository.changeset(repository, %{})
  end
end
