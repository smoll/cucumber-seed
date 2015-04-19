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
      @browser.close # if a page hangs this will fail with a selenium unknown error
    ensure
      @docker.tear_down if @docker
    end

    def restart
      stop
      start(name: @name, headless: @headless)
    end
  end # singleton methods
end
