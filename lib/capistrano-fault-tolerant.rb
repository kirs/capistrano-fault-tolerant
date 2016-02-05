require 'sshkit'
require 'thread'
require_relative 'capistrano-fault-tolerant/failed_hosts'

module CapistranoFaultTolerant
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

            # returns false if there are too many failed servers
            # raise back
            unless options[:failed_hosts].push(h)
              raise
            end
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
