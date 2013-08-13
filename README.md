# ipswitch

ipswitch is a tool to migrate IP addresses on the fly to another host without downtime.

It connects to the hosts via SSH and uses the "ip" command to add/remove IP addresses.
For IPv4, it then uses arping to notify other hosts about the IP change.

I use this tool when doing maintenance tasks on e.g. application servers, as well as managing shared master IPs for database failover setups.

This tool was build to maintain IP addresses in a backnet. *Keep in mind, that if you take away the IP you are using for your SSH connection, there might be unexpected results*

## Installation

    $ gem install ipswitch

## Usage

Migrate IP address from one host to another

    $ ipswitch migrate maintenance.node failover.node

    maintenance.node: Getting IP for interface eth0
    maintenance.node: Found IP 192.168.1.2/24
    failover.node: Adding IP address 192.168.1.2/24 to interface eth0
    failover.node: Running arpping
    failover.node: 3 packets transmitted, 0 packets received, 100% unanswered (0 extra)
    maintenance.node: Removing IP address 192.168.1.2/24 from interface eth0

**Note:** ipswitch automatically detects and uses the (primary) IP of the specified interface (default: eth0)

After the maintenance, migrate it back to the original host

    $ ipswitch migrate failover.node maintenance.node --ip 192.168.1.2/24

    maintenance.node: Adding IP address 192.168.1.2/24 to interface eth0
    maintenance.node: Running arpping
    maintenance.node: 3 packets transmitted, 0 packets received, 100% unanswered (0 extra)
    failover.node: Removing IP address 192.168.1.2/24 from interface eth0

**Note:** As eth0 now has two IP addresses, you need to specify which once to migrate. If the original node reclaimed the IP automatically (e.g. due to a reboot), ipswitch still works.

You can also use ipswitch to just add/remove IP addresses from your nodes

    $ ipswitch add --ip 192.168.1.1/24 yourappserver.node
    $ ipswitch del --ip 192.168.1.1/24 yourappserver.node

Assign an IP to an interface other than eth0 and do not use arping to broadcast IP

    $ ipswitch add --interface eth1 --ip 192.168.1.1/24 --no-broadcast yourappserver.node

Managing IPv6 addresses is also possible

    $ ipswitch add --family inet6 --ip fe80::abcd:66ff:fede:9999 yourappserver.node
    $ ipswitch del --family inet6 --ip fe80::abcd:66ff:fede:9999 yourappserver.node


**Hint:** Use --dryrun to see what's going to happen without actually doing anything


### Options

    [--user=USER]            # ssh username
                             # Default: root
    [--port=N]               # ssh port
                             # Default: 22
    [--interface=INTERFACE]  # interface name
                             # Default: eth0
    [--family=FAMILY]        # protocol family [inet|inet6]
                             # Default: inet
    [--ip=IP]                # IP address to remove/add/migrate
    [--broadcast]            # use arping to broadcast new IP (IPv4 only)
                             # Default: true
    [--count=N]              # number of broadcasts to send
                             # Default: 3
    [--debug]                # talk a lot while running
    [--dryrun]               # do not actually perform anything


## Caveats

Currently only works when using SSH keys for authenticating at your hosts.

The following features are planned

* Password support
* SOCKS proxy support)
* Ability to specify SSH keyfile
* Support for sudo


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
