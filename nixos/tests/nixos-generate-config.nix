import ./make-test-python.nix ({ lib, ... } : {
  name = "nixos-generate-config";
  meta.maintainers = with lib.maintainers; [ basvandijk ];
  machine = {
    system.nixos-generate-config.configuration = ''
      # OVERRIDDEN
      { config, pkgs, ... }: {
        imports = [ ./hardware-configuration.nix ];
      $bootLoaderConfig
      }
    '';
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("nixos-generate-config")

    # Test if the configuration really is overridden
    machine.succeed("grep 'OVERRIDDEN' /etc/nixos/configuration.nix")

    # Test of if the Perl variable $bootLoaderConfig is spliced correctly:
    machine.succeed(
        "grep 'boot\\.loader\\.grub\\.enable = true;' /etc/nixos/configuration.nix"
    )
  '';
})