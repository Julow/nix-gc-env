# nix-gc-env

Remove older generations before running the garbage collector.

Unlike the `--delete-older-than` option that can be passed to the
`nix.gc.options` option, this uses `nix-env --delete-generations`.
This allows to specify a number of generation to keep, removing the risk of
removing more.

This applies to every profiles (system, users, home-manager).

## Usage in a NixOS configuration

```nix
{ config, pkgs, nix-gc-env, ... }:

{
  imports = [
    nix-gc-env.nixosModules.default
  ];

  # Run the GC weekly keeping the 5 most recent generation of each profiles.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    delete_generations = "+5";
  };
}
```
