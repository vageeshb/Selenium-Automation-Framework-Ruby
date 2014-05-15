class Reader
  attr_accessor :url, :execution_hash
  def initialize(filename)
    @filename = filename.to_s
    @execution_hash = Hash.new()
  end

  def status
    FWConfig.log_break
    print "Parsing file: #{@filename}"
    FWConfig.log_break
    filepath =  File.expand_path("../data/#{@filename}", File.dirname(__FILE__))
    book = Spreadsheet.open filepath
    print "Number of sheets in data file: #{book.worksheets.count} ["
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
    config_sheet = book.worksheet 0
    config_sheet.drop(1).each do |row|
      @url = row[0]
      print "URL: #{row[0]}\nDriver Type: #{row[1]}\nPerform Default steps: #{row[2]}\n"
      @default_steps = row[2]
    end

    FWConfig.log_break

    # Summarize Execution Manager Sheet
    print "\nExecution Manager:\n\n"
    execution_sheet = book.worksheet 1
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
    print "Total number of tests to execute: #{counter}"
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
        true
      else
        print "\nALERT: Config specifies 'Default steps: Y', but could not find default steps in workbook.\n\nDo you want to continue? (y/N) "
        if gets.chomp! =~ /y/i
          true
        else
          false
        end
      end
    else
      return true
    end
  end

 
end