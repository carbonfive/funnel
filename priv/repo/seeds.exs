# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

alias Funnel.Repo

Repo.insert!(%Funnel.Git.Strategy{name: "Rebase"})
Repo.insert!(%Funnel.Git.Strategy{name: "Squash"})
Repo.insert!(%Funnel.Git.Strategy{name: "Sawtooth"})
