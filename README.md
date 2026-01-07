# devgateway

## Install

Setup your virtualenv and install all dependencies with:

```bash
just install
```

## Build

To build all the projects in the repo:

```bash
just build
```

## Running Background Services

To run the necessary dependent services in background mode:

```bash
just services-up
```

To stop them:

```bash
just services-down
```

## Clean

To remove all runtime data from `var`:

```bash
just clean
```
