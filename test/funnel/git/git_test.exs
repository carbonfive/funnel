defmodule Funnel.GitTest do
  use Funnel.DataCase

  alias Funnel.Git

  describe "strategies" do
    alias Funnel.Git.Strategy

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def strategy_fixture(attrs \\ %{}) do
      {:ok, strategy} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Git.create_strategy()

      strategy
    end

    test "list_strategies/0 returns all strategies" do
      strategy = strategy_fixture()
      assert Git.list_strategies() == [strategy]
    end

    test "get_strategy!/1 returns the strategy with given id" do
      strategy = strategy_fixture()
      assert Git.get_strategy!(strategy.id) == strategy
    end

    test "create_strategy/1 with valid data creates a strategy" do
      assert {:ok, %Strategy{} = strategy} = Git.create_strategy(@valid_attrs)
      assert strategy.description == "some description"
      assert strategy.name == "some name"
    end

    test "create_strategy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Git.create_strategy(@invalid_attrs)
    end

    test "update_strategy/2 with valid data updates the strategy" do
      strategy = strategy_fixture()
      assert {:ok, strategy} = Git.update_strategy(strategy, @update_attrs)
      assert %Strategy{} = strategy
      assert strategy.description == "some updated description"
      assert strategy.name == "some updated name"
    end

    test "update_strategy/2 with invalid data returns error changeset" do
      strategy = strategy_fixture()
      assert {:error, %Ecto.Changeset{}} = Git.update_strategy(strategy, @invalid_attrs)
      assert strategy == Git.get_strategy!(strategy.id)
    end

    test "delete_strategy/1 deletes the strategy" do
      strategy = strategy_fixture()
      assert {:ok, %Strategy{}} = Git.delete_strategy(strategy)
      assert_raise Ecto.NoResultsError, fn -> Git.get_strategy!(strategy.id) end
    end

    test "change_strategy/1 returns a strategy changeset" do
      strategy = strategy_fixture()
      assert %Ecto.Changeset{} = Git.change_strategy(strategy)
    end
  end
end
