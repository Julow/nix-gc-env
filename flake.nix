{
  outputs = { self, ... }:
  {
    nixosModules.default = import ./nix_gc_env.nix;
  };
}
