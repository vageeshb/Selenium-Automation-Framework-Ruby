require "./bin/main.rb"

# Instantiate Framework class
f = Framework.new

# Main driver
if ARGF.argv.empty?
  # No Options given, provide CLI
  f.interface
else
  # CL Options given, parse the options and execute
  args = ARGF.argv

  # Help option
  if args.index('-h') || args.index('--help')
    FWConfig.log_break
    print "\nSelenium Automation Framework\n"
    FWConfig.log_break
    print "Command Line Options:\n\n
    -d [Data File]     : Execute testing with using data from [Data File]\n
    -e [Email address] : Email last test result report to [Email address]\n
    -t                 : Create default data template in /data/ folder [NOTE: Cannot be clubbed with other options]\n"
    FWConfig.log_break
    exit
  end

  # Store other options
  create_template = args.index('-t')
  data_file = args[args.index('-d') + 1] if args.index('-d')
  address = args[args.index('-e') + 1] if args.index('-e')

  # '-t' option specified
  if create_template
    f.create_template
    exit
  end

  # '-d' option specified, read data file following '-d'
  if data_file
    f.execute(data_file)
  end

  # '-e' option specified, read email address following '-e'
  if address    
    f.email(address)
  end
end