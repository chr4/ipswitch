# Ipswitch

Ipswitch is a tool to migrate IP an addresse on the fly to another host without downtime.

It connects to a remote host via SSH and uses the "ip" command to add/remove IP addresses.
For IPv4, it then uses arping to notify other hosts about the IP change.


## Installation

    $ gem install ipswitch

## Usage

Assign an IP address to a host

    $ ipswitch add --ip 192.168.1.1/24 yourappserver.node

Assign it to an interface other than eth0 and do not use arping to broadcast IP

    $ ipswitch add --interface eth1 --ip 192.168.1.1/24 --no-broadcast yourappserver.node

Assign an IPv6 address

    $ ipswitch add --family inet6 --ip fe80::abcd:66ff:fede:9999 yourappserver.node

Switch IP address from one host to another

    $ ipswitch migrate your.failed.node failover.node

Use --dryrun to see what's going to happen without actually doing anything


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
