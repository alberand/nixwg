{
  config,
  pkgs,
  ip ? "10.100.0.1",
  port ? 51820,
  peers ? [],
  extInterface ? "eth0",
  ...
}: {
  age.secrets.srvprivate.file = ./secrets/server.private.age;

  environment.systemPackages = with pkgs; [
    iproute2
  ];
  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = extInterface;
  networking.nat.internalInterfaces = ["wg0"];

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 port ];
  };

  networking = {
    dhcpcd.enable = false;
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "${ip}/32" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = port;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${ip}/32 -o ${extInterface} -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${ip}/32 -o ${extInterface} -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = config.age.secrets.srvprivate.path;

      peers = peers;
      #[
      #  # List of allowed peers.
      #  {
      #    publicKey = "{client public key}";
      #    allowedIPs = ["10.100.0.2/32"];
      #  }
      #  {
      #    publicKey = "{john doe's public key}";
      #    allowedIPs = ["10.100.0.3/32"];
      #  }
      #];
    };
  };
}
