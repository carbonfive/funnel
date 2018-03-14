# Funnel

A little CI server for git hygiene. Written in Elixir.

Rationale: [Always Squash and Rebase your Git Commits](https://blog.carbonfive.com/2017/08/28/always-squash-and-rebase-your-git-commits/)

## Using funnel on a project

1. Visit the Funnel homepage: [https://github.com/apps/funnel](https://github.com/apps/funnel)

2. Click `Configure`

3. Select the organization and project(s) you want to use Funnel on

That's it! Now, whenver you submitted a Pull Request, Funnel will warn you anytime your new branch is not rebased and squashed against the base branch. And Funnel keeps things up to date -- if the base branch changes, the branch being PR'd will fail Funnel until it's rebased and squashed against the updated base branch.

## Developing

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Source environment vars with `source .env`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

### Environment

Use [direnv](https://github.com/direnv/direnv) to manage local env variables.

```bash
brew install direnv
```

An example of an .envrc file.

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
