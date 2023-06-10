{ config, lib, pkgs, ... }:

# Remove older generations before running the garbage collector.
#
# Unlike the [--delete-older-than] option that can be passed to
# [nix.gc.options], this script uses [nix-env --delete-generations].
# This allows to specify a number of generation to keep, removing the risk of
# removing all older generations.
#
# This applies to every profiles (system, user profile, home-manager).
#
# This module requires [nix.gc.automatic = true;] to be set and must be enabled
# by setting [nix.gc.delete_generations = true;].

with lib;

let
  conf = config.nix.gc;

  clean_profiles = pkgs.writeShellScript "clean_profiles.sh" ''
    PATH="${pkgs.nix}/bin:$PATH"
    . ${./clean_profiles.sh} ${escapeShellArg conf.delete_generations}
  '';

in {
  options.nix.gc = {
    delete_generations = mkOption {
      type = types.str;
      default = null;
      example = "+5";
      description = ''
        Argument passed to [nix-env --delete-generations]. The default of '+5'
        means to keep the 5 most recent generations of each profiles.
      '';
    };
  };

  config = mkIf (conf.delete_generations != null) {
    assertions = [{
      assertion = config.nix.gc.automatic;
      message =
        "'nix.gc.delete_generations' requires 'nix.gc.automatic' to be 'true'.";
    }];

    systemd.services.nix_gc_env = {
      wantedBy = [ "nix-gc.service" ];
      before = [ "nix-gc.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = clean_profiles;
      };
    };
  };
}
