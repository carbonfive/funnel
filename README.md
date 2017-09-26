# Funnel

A little CI server for git hygiene. Written in Elixir.

## Setup

### Dependencies

You'll need Elixir, obvs so `brew install elixir`

Then:

```elixir
mix deps.get
mix deps.compile
```

### Environment

To authenticate for Github's API, we need a token. Generate that on Github, and then create a `.env` file that looks like:

```bash
export GITHUB_API_KEY=ABCED1234
```

### Github Webhook configuration

[Github Webhook How-to](https://developer.github.com/webhooks/creating/)

## Running

You'll have to `source .env` manually before you run the app so...

```bash
source .env
iex -S mix
```

## Testing

```bash
mix test
```

## Deploying

```bash
docker build -t build-funnel -f docker/Dockerfile.build .
docker run -v $PWD/releases:/app/releases build-funnel
```
