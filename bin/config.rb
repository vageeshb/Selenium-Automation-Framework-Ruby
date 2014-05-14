require "selenium-webdriver"

class FWConfig
  def initialize
    @driver = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new :timeout => 3
  end

  def getDriver
    return @driver, @wait
  end
end

class TestFailureError < RuntimeError
  attr_accessor :message
  def initialize(msg=nil)
    if !msg
      @message = "FAIL: No reason specified."
    else
      @message = "FAIL: " + msg.to_s
    end
  end
end