require 'net/ssh'
require 'ipaddress'
require 'rainbow'

module Ipswitch
  class Ssh
    # TODO
    # - sudo support
    # - proxy support
    # - password
    # - specify id_dsa/rsa

    def initialize(host, options={})
      @host = host
      @options = options

      begin
        @ssh = Net::SSH.start(@host, @options[:user], { port: @options[:port] })

        # if block is given, execute everything, then close connection
        if block_given?
          yield(self)
          @ssh.close
        end

      rescue SocketError => e
        abort "Could not connect to #{@options[:user]}@#{@host}: #{e.message}"
      end
    end

    def exec(command, options={})
      options = { safe: false }.merge(options)

      stdout = ''
      stderr = ''
      exit_code = nil
      exit_signal = nil

      say(command, debug: true) if @options[:debug]

      # if this is a save command, execute it even when in dryrun mode
      if @options[:dryrun] and not options[:safe]
        return { exit_code: 0, stdout: 'dry run -- no output' }
      end

      @ssh.open_channel do |channel|
        channel.exec command do |ch, success|
          abort 'Could not execute command (ssh.channel.exec)' unless success

          channel.on_data { |ch, data| stdout << data }
          channel.on_extended_data { |ch, type, data| stderr << data }
          channel.on_request('exit-status') { |ch, data| exit_code = data.read_long }
          channel.on_request('exit-signal') { |ch, data| exit_signal = data.read_long }
        end
      end

      @ssh.loop
      { stdout: stdout, stderr: stderr, exit_code: exit_code, exit_signal: exit_signal }
    end

    def ip(command, ip)
      ret = exec("ip addr #{command} #{ip.to_string} dev #{@options[:interface]}")[:exit_code]

      unless ret == 0
        say "Unable to set IP to #{ip.to_string} (interface: #{@options[:interface]})"
        return false
      end

      true
    end

    def ip_add(ip)
      say "Adding IP address #{ip.to_string} to interface #{@options[:interface]}"
      ip('add', ip)
    end

    def ip_del(ip)
      say "Removing IP address #{ip.to_string} from interface #{@options[:interface]}"
      ip('del', ip)
    end

    def get_ip
      say "Getting IP for interface #{@options[:interface]}"
      ip_info = exec("ip -oneline -family #{@options[:family]} addr list dev #{@options[:interface]}", safe: true)

      begin
        ip = IPAddress(ip_info[:stdout].match(/.*#{@options[:family]}\s(\S+)\s.*/)[1])
      rescue => e
        say "could not get IP address: #{e.message}"
        return false
      end

      say "Found IP #{ip.to_string}"
      ip
    end

    def arping(ip)
      unless exec('which arping', safe: true)[:exit_code] == 0
        say 'arping not installed, skipping'
        return false
      end

      arping = "arping -B -S #{ip}"
      arping << " -i #{@options[:interface]}" if @options[:interface]
      arping << " -c #{@options[:count]}"     if @options[:count]
      arping << " |tail -n1"

      say 'Running arpping'
      say exec(arping)[:stdout]
    end

    def rdisc6(ip)
      # TODO
    end

    def broadcast(ip)
      case @options[:family]
      when 'inet'
        arping(ip)
      when 'inet6'
        rdisc6(ip)
      end
    end

    private

    def say(msg, options={})
      if options[:debug]
        puts "  --> #{msg}".foreground(:yellow)
      else
        puts "#{@host.foreground(:blue)}: #{msg.foreground(:green)}"
      end
    end
  end
end
