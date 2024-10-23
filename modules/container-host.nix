{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "enp2s0";
  };

  networking.firewall.trustedInterfaces = [ "ve-*" ];
}
