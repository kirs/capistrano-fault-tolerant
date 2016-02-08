require 'sshkit'
require 'thread'

module CapistranoFaultTolerant
  class FailedHosts
    TooManyHostsFailedError = Class.new(StandardError)

    def initialize(total_hosts, tolerance)
      @max_hosts_to_fail = (total_hosts * tolerance).floor
      @hosts = Set.new
    end

    attr_reader :hosts

    def push(host)
      if @hosts.size >= @max_hosts_to_fail
        raise TooManyHostsFailedError, "the limit of failed hosts is full. Failed hosts: #{@hosts.to_a.join("\n")}"
      end

      @hosts << host
      if CapistranoFaultTolerant.on_failed_host
        CapistranoFaultTolerant.on_failed_host.call(host)
      end
    end

    def include?(host)
      @hosts.include?(host)
    end
  end

  def self.on_failed_host
    @on_failed_host
  end

  def self.on_failed_host=(val)
    @on_failed_host = val
  end

  class Runner < SSHKit::Runner::Abstract
    def execute
      threads = []
      hosts.each do |host|
        threads << Thread.new(host) do |h|
          begin
            backend(h, &block).run
          rescue StandardError, Errno::ETIMEDOUT, Net::SSH::ConnectionTimeout => e
            b = SSHKit.config.backend.new(h)
            b.error "Exception while executing #{host.user ? "as #{host.user}@" : "on host "}#{host}: #{e.message}"

            options[:failed_hosts].push(h)
          end
        end
      end
      threads.map(&:join)
    end
  end

  module ExtendedDSL
    def on(hosts, options={}, &block)
      if options[:failure_tolerance]
        options[:failed_hosts] = CapistranoFaultTolerant::FailedHosts.new(hosts.size, options.delete(:failure_tolerance))
        options[:in] = CapistranoFaultTolerant::Runner
      end
      super(hosts, options, &block)
    end
  end
end

if defined?(Capistrano)
  self.extend CapistranoFaultTolerant::ExtendedDSL
else
  raise "capistrano_fault_tolerant gem should be required only in Capfile"
end
