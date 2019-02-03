# docker-compose-openvpn-pihole
OpenVPN + Pi-Hole +Docker-Compose

Projects Used:

* https://github.com/kylemanna/docker-openvpn
* https://github.com/pi-hole/docker-pi-hole/
* For Inspiration: https://github.com/rabbl/OpenVPN-PIHole

## Setup / Initialization

There is setup the user must do prior to using this, as follows:

* Pi-Hole
* OpenVPN
  * Server
  * Client

### Pi-Hole

I came to this with a pre-configured pi-hole, so you'll want to go through that inside an Ubuntu container (note: you may need to hack up its install script to work around some containerization limitations) or outside. Copy the configuration to [./pihole/pihole](./pihole/pihole) directory. Note that the provided [seupVars.conf](./pihole/pihole/seupVars.conf) and [01-pihole.conf](./pihole/dnsmasq.d/01-pihole.conf) are for reference only.

Next, edit [.env](./.env) file, such as the `PIHOLE_WEBPW` setting.

### OpenVPN

There are two things to do for OpenVPN, the server settings and then clients.

The server can follow the setup for the [upstream](https://github.com/kylemanna/docker-openvpn) docker-openvpn project for both client and server.

In brief, however the steps are to configure the server and then clients. By way of disclaimer, @lisa came to the containerization of her configuration with a "bare metal" installation so the steps are not guaranteed. Refer to the [upstream](https://github.com/kylemanna/docker-openvpn) project for more thorough explanation.

In the documentation the VPN endpoint (that is, where clients connect) is `vpn-endpoint.example.com`. The client will be called `client`. The VPN client range will be `10.100.0.0/24` with the inside-docker network device as `tun1`.

#### OpenVPN Server

**WARNING: This configuration will route _ALL_ traffic over the VPN.**

1. Initialize the configuration with 

        docker-compose run --rm openvpn ovpn_genconfig -u vpn-endpoint.example.com -N -z -d -s 10.100.0.0/24 -p "remote-gateway 10.100.0.1" -n 10.100.0.2

2. Initialize the server's crypto (PKI) and when prompted, provide passphrases and then the VPN endpoint, `vpn-endpoint.example.com` (for "Common Name").

        docker-compose run --rm openvpn ovpn_initpki

#### OpenVPN Client

1. Create a client certificate, providing the passphrases as appropriate during server configuration.

        docker-compose run --rm openvpn easyrsa build-client-full client

2. Obtain the client configuration

        docker-compose run --rm openvpn ovpn_getclient client > client.ovpn

The client configuration can be distributed to the client at this time.


## Controlling the Composition

Start the stack with `docker-compose up -d` once all configuration steps are complete, and stop via `docker-compose down`.

## DISCLAIMER

This repository is provided "as-is" and without any warranty. It may cause data loss, or due to misconfiguration cause your software to be exposed to the Internet. By using the software you assume all risks.