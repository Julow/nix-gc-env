# nix-gc-env

Remove older generations before running the garbage collector.

Unlike the `--delete-older-than` option that can be passed to the
`nix.gc.options` option, this uses `nix-env --delete-generations`.
This allows to specify a number of generation to keep and does not risk
removing too much.

This applies to every profiles (system, users, home-manager).

## Usage in a NixOS configuration

```nix
{
  # Run the GC weekly keeping the 5 most recent generation of each profiles.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    delete_generations = "+5"; # Option added by nix-gc-env
  };
}
```

### As a flake input

`flake.nix`:

```nix
{
  inputs = {
    # ...
    nix-gc-env.url = "github:Julow/nix-gc-env";
  };

  outputs = inputs:
    let
      mk_nixos = path:
        import "${inputs.nixpkgs}/nixos/lib/eval-config.nix" {
          system = "x86_64-linux";
          # Make sure to pass inputs as special args to make nix-gc-env
          # available to the configuration:
          specialArgs = inputs;
          modules = [ path ];
        };

    in {
      nixosConfigurations.default = mk_nixos ./configuration.nix;
    };
}
```

`configuration.nix`:

```nix
{ config, pkgs, nix-gc-env, ... }:

{
  imports = [
    nix-gc-env.nixosModules.default
  ];

  # ...
}
```

### Using fetchGit

`configuration.nix`:

```nix
{ config, pkgs, ... }:

let
  # Not using 'pkgs.fetchgit' because as that would cause an infinite recursion
  nix-gc-env = builtins.fetchGit {
    url = "https://github.com/Julow/nix-gc-env";
    rev = "4753f3c95891b711e29cb6a256807d22e16cf9cd";
  };

in {
  imports = [
    (import "${nix-gc-env}/nix_gc_env.nix")
  ];

  # ...
}
```
