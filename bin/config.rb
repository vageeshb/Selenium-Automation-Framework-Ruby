require "selenium-webdriver"
require "spreadsheet"

class FWConfig
  def getDriver
    @driver = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new :timeout => 3
    return @driver, @wait
  end

  def createFolder(folder_name)
    folder_path = File.expand_path("../reports/#{folder_name}", File.dirname(__FILE__))
    Dir.mkdir(folder_path, 0700) if !(Dir.exists? folder_path)
  end

  def self.log_break
    print "\n--------------------------------------------------------------------------------\n"
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