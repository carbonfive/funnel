# Funnel

A little CI server for git hygiene. Written in Elixir.
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Source environment vars with `source .env`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

### Environment

To authenticate for Github's API, we need a token. Generate that on Github, and then create a `.env` file that looks like:

```bash
export PORT=4000
export GITHUB_CLIENT_ID=23p8uqnj
export GITHUB_CLIENT_SECRET=gs084kjn
export GITHUB_PRIVATE_KEY=5537sdkbhj
```

## Testing

```bash
mix test
```

### Recording Webhooks for Testing

Insert this in the `events` handler in `router.ex`:

```elixir
File.write!("./test.json", Poison.encode!(conn.body_params), [:binary])
```
