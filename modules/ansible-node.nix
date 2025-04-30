{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [ (python3.withPackages (ps: [ ps.packaging ])) ];
}
