require "./bin/executor"
require "./bin/reader"

print "\nPlease enter the data file [In /data/ folder]: "
filename = gets.chomp!
if File.exists? "./data/" + filename.to_s
  
  r = Reader.new(filename)
  r.status
  exec = Executor.new(r.url, r.execution_hash)
  print "Initiate Test Run? (Y/N) "
  if gets.chomp! =~ /y/i
    print "\n=========================================================\n"
    print "Started Test Run at: #{Time.new.strftime("%H:%M:%S")}\n"
    print "=========================================================\n"
    print "\nTest Report at: /reports/#{exec.execute}.html\n\n"
    print "=========================================================\n"
    print "Completed Test Run at: #{Time.new.strftime("%H:%M:%S")}\n"
    print "=========================================================\n"
  else
    print "\nThank You\n"
  end
else
  print "\nFile could not be found! Exiting!\n"
end