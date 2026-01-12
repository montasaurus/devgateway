# devgateway

A tiny HTTP gateway that routes `.local` domains to local dev servers with [OrbStack](https://orbstack.dev/).

`http://localhost:3000` -> `https://myproj.local`

`http://localhost:8000` -> `https://api.myproj.local`

> [!IMPORTANT]
> This is an alpha / experimental project.

## How it works

- Set environment variables in the form `HOST__{name}={port}`.
  - Requests for `{name}.{domain}` are proxied to the host machine on `{port}`.
  - `HOST__default` is used as a fallback for the bare domain (and any unmatched
    hosts).
- Set the `dev.orbstack.domains` label to the `.local` domains you want to use (including a wildcard).

The container runs Caddy and generates its config at startup from the `HOST__*`
variables.

The container accepts connections on port 80.

## Example

Assume you have dev servers running that you want to reach via `myproj.local`:

- `localhost:8000` (API)
- `localhost:3000` (web)

### Docker Compose

```yaml
services:
  devgateway:
    image: montasaurus/devgateway
    labels:
      - dev.orbstack.domains=*.myproj.local # wildcard for myproj.local and all subdomains
    environment:
      HOST__API: "8000" # send api.myproj.local to localhost:8000
      HOST__default: "3000" # send myproj.local to localhost:3000
```

## Sources

Github: [montasaurus/devgateway](https://github.com/montasaurus/devgateway)

Docker Image: [montasaurus/devgateway](https://hub.docker.com/r/montasaurus/devgateway)
