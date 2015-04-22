class Browser
  class << self
    def instance
      @browser
    end

    def start(name: 'chrome', headless: true)
      @name, @headless = name, headless
      return @browser = Watir::Browser.new(name.to_sym) unless @headless

      @docker = Docker::Selenium.new(name)
      @browser = Watir::Browser.new(
        :remote,
        url: @docker.url,
        desired_capabilities: { 'browserName' => name }
      )
    end

    def stop
      begin
        @browser.close # if a page hangs this will fail with a selenium unknown error
      rescue Selenium::WebDriver::Error::UnknownError
        puts 'Failed to close old browser (possibly because page is hanging); starting new one!'
      end

      @docker.tear_down if @docker
    end

    def restart
      stop
      start(name: @name, headless: @headless)
    end
  end # singleton methods
end
