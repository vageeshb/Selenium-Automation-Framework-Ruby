require "spreadsheet"
require "./bin/config.rb"
require './bin/reporter'

Spreadsheet.client_encoding = 'UTF-8'

class Executor
  attr_accessor :execution_hash
  
  # Read and initialize config settings
  def initialize(url, execution_hash)
    @url = url
    @execution_hash = execution_hash
  end

  def execute
    results = []
    print "\n=========================================================\n"
    print "Test Execution Status:\n"
    begin
      @execution_hash.each do |module_name, test_set|
        print "\nExecuting module - '#{module_name}':\n\n"
        new_test = 0
        test_set.each do |test|
          if new_test != test[0]
            @driver, @wait = FWConfig.new.getDriver
            @driver.get @url
            new_test = test[0]
            print ""
          end
          test_name = test[0]
          test_step_name = test[1]
          locator_type = test[2]
          locator_value = test[3]
          action = test[4]
          value = test[5]
          result = []
          result << module_name << test_name << test_step_name
          if @driver
            if action != "assert" 
              element = find :"#{locator_type}" => locator_value
              if !element.is_a?(String)
                status = perform(element, action, value)
                result << status
                test_status = '.'
              else
                result << element
                test_status = 'F'
              end
            else
              status = assert(locator_type, locator_value, value)
              result << status
              if status == "PASS"
                test_status = "."
              else
                test_status = "F"
              end
            end
          else
            result << "SKIP"
            test_status = "S"
          end
          print test_status
          results << result if !result.empty?
        end
        teardown if @driver
      end
    rescue Exception => e
      p e.message
    end
    r = Reporter.new
    r.build_report(results)
    print "\n\n=========================================================\n"
    return r.write
  end

  private
    # Driver find element function
    def find hash
      begin
        @wait.until { @driver.find_element hash }
        return @driver.find_element(hash)
      rescue
        hash.each do |key, value|
          teardown
          return TestFailureError.new("Could not locate element: " + key.to_s + "=>" + value.to_s).message
        end
      end
    end

    def perform(element, action, value)
      case action
        when "input"
          element.send_keys value
          return "PASS"
        when "click"
          element.click
          return "PASS"
        else return "FAIL"
      end
    end

    def assert(locator_type, locator_value, value)
      case locator_type
        when "url"
          if @driver.current_url == value 
            return "PASS" 
          else 
            return TestFailureError.new.message
          end
      end
    end

    def teardown
      @driver.quit
      @driver = nil
    end

end