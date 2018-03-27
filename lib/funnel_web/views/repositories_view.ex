defmodule FunnelWeb.RepositoriesView do
  use FunnelWeb, :view
  alias Funnel.GitHub.Repository
  alias Funnel.Git

  @nil_strategy_name "None"

  @spec repository_name(%Repository{}) :: binary
  def repository_name(repository) do
    repository.details.owner <> "/" <> repository.details.name
  end

  @spec repository_strategy_name(%Repository{}) :: binary
  def repository_strategy_name(repository) do
    case repository.strategy do
      nil ->
        @nil_strategy_name
      strategy ->
        strategy.name
    end
  end

  @spec repository_strategy_name(list(%Git.Strategy{})) :: list({})
  def repository_strategy_options(strategies) do
    Enum.map(strategies, &{&1.name, &1.id})
    |> List.insert_at(0, {@nil_strategy_name, ""})
  end

end
