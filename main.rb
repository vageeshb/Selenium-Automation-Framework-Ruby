require "./bin/config"
require "./bin/reader"
require "./bin/reporter"
require "./bin/executor"

print "\nPlease enter the data file [In /data/ folder]: "
filename = gets.chomp!
filename = filename.to_s + ".xls" if !(filename =~ /.xls/i)
if File.exists? "./data/" + filename.to_s
  
  r = Reader.new(filename)
  if r.status
    exec = Executor.new(r.url, r.execution_hash)
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

