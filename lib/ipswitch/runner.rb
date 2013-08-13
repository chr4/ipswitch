require 'thor'

module Ipswitch
  class Runner < Thor
    check_unknown_options!

    # default options for all tasks
    def self.default_options
      method_option 'user',      :type => :string,  :desc => 'ssh username', :default => 'root'
      method_option 'port',      :type => :numeric, :desc => 'ssh port', :default => 22
      method_option 'interface', :type => :string,  :desc => 'interface name', :default => 'eth0'
      method_option 'family',    :type => :string,  :desc => 'protocol family [inet|inet6]', :default => 'inet'
      method_option 'ip',        :type => :string,  :desc => 'IP address to remove/add/migrate'
      method_option 'broadcast', :type => :boolean, :desc => 'use arping to broadcast new IP (IPv4 only)', :default => true
      method_option 'count',     :type => :numeric, :desc => 'number of broadcasts to send', :default => 3
      method_option 'debug',     :type => :boolean, :desc => 'talk a lot while running', :default => false
      method_option 'dryrun',    :type => :boolean, :desc => 'do not actually perform anything', :default => false
    end

    desc 'migrate', 'migrate IP from one host to another'
    default_options
    def migrate(source, target)
      ssh_source = Ipswitch::Ssh.new(source, options)
      ssh_target = Ipswitch::Ssh.new(target, options)

      # either use ip specified by --ip option
      # or try getting it from source host
      if options[:ip]
        ip = IPAddress(options[:ip])
      else
        ip = ssh_source.get_ip
      end

      # assign IP to target
      ssh_target.ip_add(ip)
      ssh_target.broadcast(ip) if options[:broadcast]

      # remove from source
      ssh_source.ip_del(ip)
    end

    desc 'add', 'add IP to host'
    default_options
    def add(host)
      abort "#{'Error:'.foreground(:red)} --ip argument is required" unless options[:ip]
      ip = IPAddress(options[:ip])

      Ipswitch::Ssh.new(host, options) do |ssh|
        ssh.ip_add(ip)
        ssh.broadcast(ip) if options[:broadcast]
      end
    end

    desc 'del', 'remove IP from host'
    default_options
    def del(host)
      abort "#{'Error:'.foreground(:red)} --ip argument is required" unless options[:ip]
      ip = IPAddress(options[:ip])

      Ipswitch::Ssh.new(host, options) do |ssh|
        ssh.ip_del(ip)
      end
    end
  end
end
