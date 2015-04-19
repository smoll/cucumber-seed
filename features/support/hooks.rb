Browser.start(headless: ENV['HEADLESS']) # TODO: replace with Envfile

Before do
  @browser = Browser.instance
end

After do |scenario|
  Browser.restart if scenario.failed?
end

at_exit do
  Browser.stop
end
