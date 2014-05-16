require "./bin/config"
class Framework
  def interface
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
      execute(filename)
      print "Do you want to email the last test result? (y/N) "
      if gets.chomp! =~ /y/i
        print "Please provide receiver's email address: "
        address = gets.chomp!
        email(address)
      end
    end
    FWConfig.log_break
  end

  def create_template
    Reader.template
    FWConfig.log_break
    print "\nTemplate created at [/data/default_template.xls].\n\nPlease edit it as per your needs and re-run the program.\n"
    FWConfig.log_break    
  end

  def email(address)

    if address && address =~ /^.+@.+$/i

      FWConfig.log_break
      print "Emailing latest test result report to: #{address}"
      FWConfig.log_break

      path = File.expand_path("../reports/", File.dirname(__FILE__))
      last_report = Dir.glob(File.join(path, '*/*.html')).max { |a,b| File.ctime(a) <=> File.ctime(b) }

      if last_report
        print "\tZipping results\n"
        zipfile_name = create_zip(last_report)
        print "\tResults archived\n\tCreating email\n"
        deliver_mail(address, zipfile_name)
        print "\tEmail sent"
        File.delete(zipfile_name)
        FWConfig.log_break
      else
        print "No test reports found! Please execute atleast 1 test run!"
        FWConfig.log_break
      end

    elsif !address
      FWConfig.log_break
      print "WARN: Email option given, but no email address found!"
      FWConfig.log_break
    else
      FWConfig.log_break
      print "WARN: Invalid email address!"
      FWConfig.log_break
    end
  end

  def execute(filename)
    # Require neccessary modules
    require "./bin/reader"
    require "./bin/reporter"
    require "./bin/executor"

    if File.exists? "./data/" + filename.to_s
      r = Reader.new(filename)
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

  end

  private
    def create_zip(filename)
      require 'zip'
      path = File.expand_path("../reports/", File.dirname(__FILE__))

      resources = []
      resources_path = File.expand_path("../reports/resources", File.dirname(__FILE__))
      resources << File.join(resources_path, 'css/bootstrap.min.css')
      resources << File.join(resources_path, 'js/bootstrap.min.js')
      resources << File.join(resources_path, 'js/report.min.js')

      report_file = filename.to_s

      error_files = Dir.glob(File.join(path, "#{filename.split('/')[-2]}/*.png"))
      archive_name = report_file.split('/').last.split('.').first
      
      zipfile_name = File.expand_path("../reports/", File.dirname(__FILE__)).to_s + "/report_archive.zip"
      
      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        zipfile.mkdir("#{archive_name}")
        zipfile.add("#{archive_name}/report.html", report_file)
        error_files.each do |file|
          zipfile.add("#{archive_name}/#{file.split('/').last.to_s}", file)
        end
        zipfile.mkdir('resources/css')
        zipfile.mkdir('resources/js')
        resources.each do |resource|
          zipfile.add('resources/css/' + resource.split('/').last.to_s, resource) if resource.to_s =~ /css/i
          zipfile.add('resources/js/' + resource.split('/').last.to_s, resource) if resource.to_s =~ /js/i
        end
      end
      zipfile_name
    end

    def deliver_mail(receiver, filename)
      require "mail"
      Mail.defaults do
        delivery_method :smtp, address: "smtp.gmail.com", user_name: 'vageesh6260@gmail.com', password: 'Samsung.s2', port: 587, authentication: 'plain', enable_starttls_auto: true
      end
      mail = Mail.new do
        from    'selenium_automation_framework@reporter.io'
        to      receiver
        subject 'SAF Test Execution Result'
        body    "Hi,\n\nThis is an auto-generated mail.\n\nPlease do not reply to this message.\n\nTest Execution Results have been attached.\n\nRegards,\nSAF Team"
        add_file filename
      end
      mail.deliver
    end
end