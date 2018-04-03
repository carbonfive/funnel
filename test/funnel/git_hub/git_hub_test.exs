defmodule Funnel.GitHubTest do
  use Funnel.DataCase

  alias Funnel.GitHub
  alias Funnel.Git

  describe "repositories" do

    setup do
      {:ok, strategy} = Git.create_strategy(%{name: "my strat"})
      {:ok, strategy: strategy}
    end

    alias Funnel.GitHub.Repository

    @valid_attrs %{git_hub_id: 123456, git_hub_installation_id: 66216}
    @update_attrs %{git_hub_id: 654321, strategy_id: nil, details: %{owner: "sara", name: "zac"}}
    @invalid_attrs %{git_hub_id: nil, details: nil}

    def repository_fixture(attrs \\ %{}) do
      {:ok, repository} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GitHub.create_repository()

      repository
    end

    test "list_repositories/0 returns all repositories" do
      repository = repository_fixture()
      assert GitHub.list_repositories() == [repository]
    end

    test "get_repository!/1 returns the repository with given id" do
      repository = repository_fixture()
      assert GitHub.get_repository!(repository.id) == repository
    end

    test "create_repository/1 with valid data creates a repository" do
      assert {:ok, %Repository{} = repository} = GitHub.create_repository(@valid_attrs)
      assert repository.git_hub_id == @valid_attrs.git_hub_id
    end

    test "get_or_create_repository_with_git_hub_id/1 finds an exisiting repository" do
      repository = repository_fixture()
      assert GitHub.get_or_create_repository_with_git_hub_id(repository.git_hub_id) == repository
    end

    test "get_or_create_repository_with_git_hub_id/1 creates a new repository" do
      assert (GitHub.get_or_create_repository_with_git_hub_id(@valid_attrs.git_hub_id, %{git_hub_installation_id: 66216})).git_hub_id == @valid_attrs.git_hub_id
    end

    test "create_repository/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = GitHub.create_repository(@invalid_attrs)
    end

    test "update_repository/2 with valid data updates the repository", ctx do
      repository = repository_fixture()
      assert {:ok, repository} = GitHub.update_repository(repository, %{@update_attrs | strategy_id: ctx[:strategy].id})
      assert repository.git_hub_id == @update_attrs.git_hub_id
    end

    test "update_repository/2 with invalid data returns error changeset" do
      repository = repository_fixture()
      assert {:error, %Ecto.Changeset{}} = GitHub.update_repository(repository, @invalid_attrs)
      assert repository == GitHub.get_repository!(repository.id)
    end

    test "delete_repository/1 deletes the repository" do
      repository = repository_fixture()
      assert {:ok, %Repository{}} = GitHub.delete_repository(repository)
      assert_raise Ecto.NoResultsError, fn -> GitHub.get_repository!(repository.id) end
    end

    test "change_repository/1 returns a repository changeset" do
      repository = repository_fixture()
      assert %Ecto.Changeset{} = GitHub.change_repository(repository)
    end
  end
end
