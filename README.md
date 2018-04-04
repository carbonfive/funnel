# Funnel

**A little CI service that makes sure your pull request is ready according to the git practices of your team.**

## Using funnel on a project

1. Visit the Funnel app listing: [https://github.com/apps/funnel](https://github.com/apps/funnel)

2. Click `Configure`

3. Select the organization and project(s) you want to use Funnel on

4. Go to [https://funnel-c5.herokuapp.com/repositories](https://funnel-c5.herokuapp.com/repositories) to configure your repositories.

That's it! 😄 Now, funnel will check and watch open pull requests to see if they are ready for merging. It can check to see if your PR is squashed into a single commit, rebased on the base branch, or both!

## Developing

### Local Setup

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

#### Environment

Use [direnv](https://github.com/direnv/direnv) to manage local env variables. Or just `source .envrc` manually.

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

#### Running

Start Phoenix server with `mix phx.server`

### Testing

```bash
mix test
```

### Deploying

```bash
git push heroku master
```

See it live at [https://funnel-c5.herokuapp.com](https://funnel-c5.herokuapp.com).

## References

### GitHub API

* [GitHub App Auth Strategy](https://developer.github.com/apps/building-integrations/setting-up-and-registering-github-apps/about-authentication-options-for-github-apps/#about-authentication-options-for-github-apps)
* [GitHub App API](https://developer.github.com/v3/apps/)
* [GitHub App Installations API](https://developer.github.com/v3/apps/installations/)
