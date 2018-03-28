{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.configure(exclude: [skip: true])
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Funnel.Repo, :manual)
