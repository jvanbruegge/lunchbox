{
  imports = [
    ./settings.nix
    ./modules/haproxy.nix
    ./modules/authentik.nix
    ./modules/postgres.nix
  ];
}
