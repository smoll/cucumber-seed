require 'addressable/uri'

module Docker
  class Selenium
    def initialize(browser_name, selenium_version = '2.45.0')
      @browser_name, @selenium_version = browser_name, selenium_version
    end

    def url
      start_up unless started?
      "http://#{ip}:#{port}/wd/hub"
    end

    def start_up
      run = Mixlib::ShellOut.new "docker run -d -P selenium/standalone-#{@browser_name}:#{@selenium_version}"
      run.run_command
      run.error! # fails on non-zero exit code

      @uid = run.stdout.strip # strip leading/trailing whitespace and newlines
      initiate_connection
      puts "Started docker container at: #{@uid}"
    end

    def tear_down
      return puts "Container (#{@uid}) appears to have already been removed!" unless started?
      rm = Mixlib::ShellOut.new "docker rm -f #{@uid}"
      rm.run_command
      rm.error!

      puts "Removed docker container: #{@uid}"
    end

    private

    def started?
      return false if @uid.nil?

      inspect = Mixlib::ShellOut.new "docker inspect #{@uid}"
      inspect.run_command
      inspect.error!
      true
    rescue Mixlib::ShellOut::ShellCommandFailed
      false
    end

    # Needed because sometimes container is started, but the port is not available for Watir to connect to
    # e.g. Connection refused - connect(2) for "192.168.59.103" port 32769 (Errno::ECONNREFUSED)
    def initiate_connection
      Retriable.retriable on: [Errno::ECONNREFUSED, Errno::EHOSTUNREACH] do
        TCPSocket.new(ip, port).close
      end
    end

    def ip
      # $DOCKER_HOST is usually only set for boot2docker or other non-native docker installs
      # Otherwise, looks like: "tcp://192.168.59.103:2376"
      docker_host = `echo $DOCKER_HOST`.strip
      return '127.0.0.1' if docker_host.empty? # if env var is not set, assume docker is on localhost
      uri = Addressable::URI.parse(docker_host)
      uri.host
    end

    def port
      # Looks like: "4444/tcp -> 0.0.0.0:4444"
      `docker port #{@uid}`.strip.split(':').last
    end
  end
end
