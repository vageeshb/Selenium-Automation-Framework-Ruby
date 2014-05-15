require "./bin/config"
require "./bin/reader"
require "./bin/reporter"
require "./bin/executor"

if ARGF.argv.empty?
  FWConfig.log_break
  print "\nWould you like to create a test execution template?(y/N) "
  if gets.chomp! =~ /y/i
    Reader.template
    print "\nTemplate created at [/data/default_template.xls].\n\nPlease edit it as per your needs and re-run the program.\n"
  else
    FWConfig.log_break
    print "\nLooking for data(xls) files in [/data] folder: \n\n"
    d = Dir.new(Dir.pwd.to_s + "/data")
    d.each {|file| print "#{file}\n" if file =~ /(.xls)$/i}
    print "\nPlease enter the data file [In /data/ folder]: "
    filename = gets.chomp!
    filename = filename.to_s + ".xls" if !(filename =~ /(.xls)/i)
    if File.exists? "./data/" + filename.to_s
      
      r = Reader.new(filename)
      if r.status
        exec = Executor.new(r.url, r.execution_hash, r.test_data)
        print "\nInitiate Test Run? (y/N) "
        if gets.chomp! =~ /y/i
          FWConfig.log_break
          print "Started Test Run at: #{Time.new.strftime("%H:%M:%S")}\n"
          FWConfig.log_break
          print "\nTest Report at: /reports/#{exec.execute}.html\n"
          FWConfig.log_break
          print "Completed Test Run at: #{Time.new.strftime("%H:%M:%S")}\n"
          FWConfig.log_break
        else
          print "\nThank You\n"
        end
      else
        print "\nThank You\n"
      end
    else
      print "\nFile could not be found! Exiting!\n"
    end
  end
  FWConfig.log_break
else
  args = ARGF.argv
  data_file = args[args.index('-d') + 1] if args.include? '-d'
  if data_file
    if File.exists? "./data/" + data_file.to_s
      r = Reader.new(data_file)
      if r.status
        exec = Executor.new(r.url, r.execution_hash, r.test_data)
        FWConfig.log_break
        print "Started Test Run at: #{Time.new.strftime("%H:%M:%S")}\n"
        FWConfig.log_break
        print "\nTest Report at: /reports/#{exec.execute}.html\n"
        FWConfig.log_break
        print "Completed Test Run at: #{Time.new.strftime("%H:%M:%S")}\n"
        FWConfig.log_break
      else
        print "\nThank You\n"
      end
    else
      print "\nFile could not be found! Exiting!\n"
    end
  else
    print "Insufficient options!!!\n"
  end
end