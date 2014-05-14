class Reporter
  attr_accessor :filename
  def initialize(filename=nil)

    time_init = Time.new.strftime("%d%m%Y_%H%M%S")
    
    if !filename
      @filename = time_init
    else
      @filename = time_init + "_#{filename.to_s}"
    end

    @f = File.new("./reports/" + @filename + ".html",  "w+")
    script = "<link rel='stylesheet' href='http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css' />"
    @head = "\n<head>\n\t<title>Test Result Run : #{time_init}</title>\n#{script}\n</head>\n"
    @summary = ""
    @table = ""
    @row_contents = ""
  end

  def build_report(results)
    
    module_list = Array.new
    test_case_list = Array.new
    test_step_list = Array.new
    status_list = Array.new
    results.each do |result|
      module_list << result[0]
      test_case_list << result[1]
      test_step_list << result[2]
      status_list << result [3]
      @row_contents += table_row(result[0], result[1], result[2], result[3])
    end
    
    module_list.uniq!
    test_case_list.uniq!

    @summary = summary(module_list, test_case_list, test_step_list, status_list)
    @table = table_wrapper
  end
  def write
    body = "\n<body>\n\t<div class='container'>\n#{@summary}\n#{@table}\n</div>\n</body>"
    @f << "<html>#{@head}#{body}</html>"
    @f.close
    return @filename
  end

  private
    def summary(module_list, test_case_list, test_step_list, status_list)
      status_count = Hash.new(0)
      status_list.each do |status| 
        if status =~ /FAIL/
          status_count["FAIL"] += 1
        else
          status_count[status] += 1
        end
      end
      "<div class='jumbotron'>\n<h1>Test Run: #{Time}</h1>\n<h3>Modules: #{module_list.count}</h3><h3>Test Cases: #{test_case_list.count}</h3><h4>Test Steps: #{test_step_list.count}</h4><h4>Pass: #{status_count["PASS"]}</h4><h4>Fail: #{status_count["FAIL"]}</h4><h4>Skip: #{status_count["SKIP"]}</h4></div>"
    end

    def table_wrapper
      "\n<table class='table table-bordered table-hover'>\n<thead>\n<tr>\n<td>\nModule Name\n</td><td>Test Name</td><td>Test Step Name</td><td>Status</td></tr></thead><tbody>#{@row_contents}</tbody></table>"
    end

    def table_row(module_name, test_name, test_step_name, status)
      case status
        when "PASS"
          "<tr class='success'><td>#{module_name}</td><td>#{test_name}</td><td>#{test_step_name}</td><td>#{status}</td></tr>\n"
        when "SKIP"
          "<tr class='warning'><td>#{module_name}</td><td>#{test_name}</td><td>#{test_step_name}</td><td>#{status}</td></tr>\n"
        else
          "<tr class='danger'><td>#{module_name}</td><td>#{test_name}</td><td>#{test_step_name}</td><td>#{status}</td></tr>\n"
      end
    end
end