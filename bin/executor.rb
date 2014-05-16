Spreadsheet.client_encoding = 'UTF-8'

class Executor
  attr_accessor :execution_hash
  
  # Read and initialize config settings
  def initialize(url, execution_hash, test_data)
    @url = url
    @execution_hash = execution_hash
    @test_data = test_data
    @time_init = Time.new.strftime("%d%m%y_%H%M%S")
  end

  # Main Execution Function
  def execute
    results = []
    FWConfig.log_break
    print "Test Execution Status:"
    begin
      if @execution_hash['before']
        before_steps = @execution_hash['before']
        @execution_hash.delete('before')
      end
      @execution_hash.each do |module_name, test_row|
        print "\n\nExecuting module - '#{module_name}':\n\n"
        new_test = 0
        test_row.each do |test|
          if new_test != test[0]
            teardown if @driver
            @driver, @wait = FWConfig.new.getDriver
            @driver.get @url
            new_test = test[0]
            print " "
          end
          if before_steps
            before_steps.each do |before_step|
              if @test_data[before_step[4]]
                result = execute_test_step(module_name, test[0], before_step[0], before_step[1], before_step[2], before_step[3], @test_data[before_step[4]])
              else
                result = execute_test_step(module_name, test[0], before_step[0], before_step[1], before_step[2], before_step[3], before_step[4])
              end
              results <<  result if !result.empty?
            end
          end
          if @test_data[test[5]]
            result = execute_test_step(module_name, test[0], test[1], test[2], test[3], test[4], @test_data[test[5]])
          else
            result = execute_test_step(module_name, test[0], test[1], test[2], test[3], test[4], test[5])
          end
          results <<  result if !result.empty?
        end
        teardown if @driver
      end
    rescue Exception => e
      p e.message
    end
    r = Reporter.new(@time_init)
    r.build_report(results)
    FWConfig.log_break
    print "\nError Screenshots in folder: /reports/errors/#{@time_init}/\n"
    return r.write
  end

  private

    # Execute test step
    def execute_test_step(module_name, test_name, test_step_name, locator_type, locator_value, action, value)
      result = []
      result << module_name << test_name << test_step_name
      if @driver
        @current_test = "#{module_name}_#{test_name}_#{test_step_name}"
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
      return result
    end
    # Driver Find Element
    def find hash
      begin
        @wait.until { @driver.find_element hash }
        return @driver.find_element(hash)
      rescue
        # Element not found -> Raise Exception, return FAIL message and take screenshot
        FWConfig.new.createFolder(@time_init)
        hash.each do |key, value|
          @driver.save_screenshot(File.expand_path("../reports/#{@time_init}/#{@current_test}.png", File.dirname(__FILE__)))
          teardown
          return TestFailureError.new("Could not locate element: " + key.to_s + "=>" + value.to_s).message
        end
      end
    end

    # Driver Execute Action
    def perform(element, action, value)
      case action
        when "input"
          element.send_keys value
          return "PASS"
        when "click"
          element.send_keys :return
          return "PASS"
        else
          # Invalid Action -> Raise Exception, return FAIL message and take screenshot
          FWConfig.new.createFolder(@time_init)
          @driver.save_screenshot(File.expand_path("../reports/#{@time_init}/#{@current_test}.png", File.dirname(__FILE__)))
          return "FAIL"
      end
    end

    # Asserting Function
    def assert(locator_type, locator_value, expected_value)
      case locator_type
        when "url"
          actual_value = @driver.current_url
          if @driver.current_url == expected_value
            return "PASS" 
          else
            FWConfig.new.createFolder(@time_init)
            @driver.save_screenshot(File.expand_path("../reports/#{@time_init}/#{@current_test}.png", File.dirname(__FILE__)))
            return TestFailureError.new("Assertion failed: Expected - '#{expected_value}', Found - '#{actual_value}'").message
          end
      end
    end

    # Close web driver function
    def teardown
      @driver.quit
      @driver = nil
    end
end