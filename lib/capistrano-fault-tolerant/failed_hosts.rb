module CapistranoFaultTolerant
  class FailedHosts
    def initialize(total_servers, tolerance)
      @max_servers_to_fail = (total_servers * tolerance).ceil
      @hosts = Set.new
    end

    attr_reader :hosts

    def push(host)
      if @hosts.size >= @max_servers_to_fail
        return false
      end

      @hosts << host
      if CapistranoFaultTolerant.on_failed_host
        CapistranoFaultTolerant.on_failed_host.call(host)
      end
      true
    end

    def include?(host)
      @hosts.include?(host)
    end

    private

    def on_new_host(host)
      # drop it
    end
  end
end
