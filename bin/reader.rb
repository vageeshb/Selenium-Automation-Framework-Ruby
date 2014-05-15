class Reader
  attr_accessor :url, :execution_hash, :test_data
  def initialize(filename)
    @filename = filename.to_s
    @execution_hash = Hash.new()
    @test_data = Hash.new()
  end

  # Class Method to create test execution template
  def self.template
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    header_format = Spreadsheet::Format.new :color => :blue, :size => 12, :horizontal_align => :center
    config = book.create_worksheet name: 'config'
    config.row(0).push 'URL', 'DRIVER', 'DEFAULT STEPS?'
    config.column(0).width = config.column(1).width = config.column(2).width = 20
    config.row(1).push 'Add your config settings here'

    em = book.create_worksheet name: 'execution_manager'
    em.row(0).push 'MODULE', 'TEST #', 'EXECUTE?'
    em.row(1).push 'Add your execution settings here'
    em.column(0).width = em.column(1).width = em.column(2).width = 20

    td = book.create_worksheet name: 'test_data'
    td.row(0).push 'NAME', 'VALUE', 'INFO'
    td.row(1).push 'Add your test data here'
    td.column(0).width = td.column(1).width = td.column(2).width = 20

    bf = book.create_worksheet name: 'before'
    bf.row(0).push 'NAME', 'LOCATOR TYPE', 'LOCATOR VALUE', 'ACTION', 'TEST DATA'
    bf.row(1).push 'Add your default steps here'
    bf.column(0).width = bf.column(1).width = bf.column(2).width = bf.column(3).width = bf.column(4).width = 20

    config.row(0).default_format = em.row(0).default_format = td.row(0).default_format = bf.row(0).default_format = header_format
    book.write File.expand_path("../data/default_template.xls", File.dirname(__FILE__))
  end

  def status
    FWConfig.log_break
    filepath =  File.expand_path("../data/#{@filename}", File.dirname(__FILE__))
    book = Spreadsheet.open filepath
    print "Number of sheets in '#{@filename}': #{book.worksheets.count} ["
    book.worksheets.each_with_index do |sheet, index|
      if index != book.worksheets.count-1
        print "#{sheet.name}, "
      else
        print "#{sheet.name}]"
      end
    end

    FWConfig.log_break

    # Summarize Config Sheet
    print "\nConfig Sheet:\n\n"
    config_sheet = book.worksheet 'config'
    config_sheet.drop(1).each do |row|
      @url = row[0]
      print "URL: #{row[0]}\nDriver Type: #{row[1]}\nPerform Default steps: #{row[2]}\n"
      @default_steps = row[2]
    end

    FWConfig.log_break

    # Summarize Execution Manager Sheet
    print "\nExecution Manager:\n\n"
    execution_sheet = book.worksheet 'execution_manager'
    print "Total number of tests defined(in exec manager): #{execution_sheet.drop(1).count}\n"
    
    counter = 0
    execution_sheet.drop(1).each do |row|
      if row[2] =~ /y/i
        if @execution_hash[row[0]].nil?
          @execution_hash[row[0]] = []
          @execution_hash[row[0]] << row[1]
        else 
          @execution_hash[row[0]] << row[1]
        end
        counter += 1
      end
    end
    print "Total number of tests to execute: #{counter}\n"
    
    FWConfig.log_break

    # Summarize Test Data
    print  "\nTest Data:\n\n"
    test_data_sheet = book.worksheet 'test_data'
    print "Total number of test data found: #{test_data_sheet.drop(1).count}\n"
    test_data_sheet.drop(1).each do |row|
      @test_data[row[0]] = row[1]
    end
    FWConfig.log_break

    @execution_hash.each do |module_name, test_list|
      execution_rows = []
      test_sheet = book.worksheet module_name
      test_sheet.drop(1).each do |row|
        if row[0] != nil
          temp = []
          row.each do |value|
            if test_list.include? row[0]
              temp << value if !value.nil?
            end
          end
          execution_rows << temp if !temp.empty?
        end
      end
      @execution_hash[module_name] = execution_rows
    end

    if (@default_steps =~ /y/i) 
      if (book.worksheet 'before')
        print "NOTE: Defaults steps provided, these steps will be executed before each of the tests.\n"
        before_sheet = book.worksheet 'before'
        @execution_hash["before"] = []
        before_sheet.drop(1).each do |row|
          temp = []
          row.each do |value|
            temp << value
          end
          @execution_hash["before"] << temp
        end
      else
        print "\nALERT: Config specifies 'Default steps: Y', but could not find default steps in workbook.\n\n"
      end
      true
    else
      true
    end
  end 
end