# ProcessmonEx

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add processmon_ex to your list of dependencies in `mix.exs`:

        def deps do
          [{:processmon_ex, "~> 0.0.1"}]
        end

  2. Ensure processmon_ex is started before your application:

        def application do
          [applications: [:processmon_ex]]
        end


## Building

```
 mix deps.get
 MIX_ENV=prod mix compile
 MIX_ENV=prod mix release

```

## Running the build
```
      Interactive: _build/prod/rel/processmon/bin/processmon console
      Foreground: _build/prod/rel/processmon/bin/processmon foreground
      Daemon: _build/prod/rel/processmon/bin/processmon start
```