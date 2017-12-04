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

An example of an .env file.

```bash
export GITHUB_APP_ID=6615
export GITHUB_PRIVATE_KEY=5537sdkbhj
export GITHUB_OAUTH_CLIENT_ID=skjsdf
export GITHUB_OAUTH_CLIENT_SECRET=9872345kbjh
```

## Testing

```bash
mix test
```

## Reference

### GitHub API

* [GitHub App Auth Strategy](https://developer.github.com/apps/building-integrations/setting-up-and-registering-github-apps/about-authentication-options-for-github-apps/#about-authentication-options-for-github-apps)
* [GitHub App API](https://developer.github.com/v3/apps/)
* [GitHub App Installations API](https://developer.github.com/v3/apps/installations/)
