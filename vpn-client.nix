{
  config,
  lib,
  pkgs,
  ip,
  publicKey,
  endpoint ? "10.100.0.1",
  port ? 51820,
  ...
}: {
  networking.firewall = {
    allowedUDPPorts = [port]; # Clients and peers can use the same port, see listenport
  };

  age.secrets.cliprivate.file = ./secrets/client.private.age;
  # Enable WireGuard
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "${ip}/32" ];
      listenPort = port; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = config.age.secrets.cliprivate.path;

      peers = [
        # For a client configuration, one peer entry for the server will suffice.

        {
          # Public key of the server (not a file path).
          publicKey = publicKey;

          # Forward only subnet
          allowedIPs = ["${endpoint}/32"];

          # Set this to the server IP and port.
          endpoint = "${endpoint}:${port}";

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
