class Reporter
  attr_accessor :filename
  def initialize(filename=nil)

    if !filename
      @filename = time_init
    else
      @filename = filename.to_s
    end
    @f = File.new(File.expand_path("../reports/", File.dirname(__FILE__)) + "/#{@filename.to_s}.html",  "w+")
    
    @summary = ""
    @table = ""
    @row_contents = ""
  end

  def build_report(results)
    module_list = Array.new
    test_case_list = Array.new
    test_step_list = Array.new
    status_list = Array.new
    module_hash = Hash.new()
    results.each do |result|
      module_hash[result[0]] = [] if !module_hash[result[0]]
      temp = [result[0],result[1],result[2],result[3]]
      module_hash[result[0]] << temp
      module_list << result[0]
      test_case_list << result[1]
      test_step_list << result[2]
      status_list << result [3]
    end
    
    module_list.uniq!
    test_case_list = test_case_list.chunk{|n| n}.map{|x| x.first}
    details(module_hash)
    @test_summary = test_summary(module_list, test_case_list, test_step_list, status_list)
    @module_summary = module_summary(module_hash)
    @details = details(module_hash)
  end

  def write
    script = "
    <link rel='stylesheet' href='../bin/resources/css/bootstrap.min.css' />
    <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js'></script>
    <script src='../bin/resources/js/bootstrap.min.js'></script>
    <script src='../bin/resources/js/report.min.js'></script>"
    head = "
    <head>
      <title>Test Result Run : #{@filename}</title>
      #{script}
    </head>"
    footer = "
    <div id='footer'>
      <div class='text-center'>
        <hr>
        <span>Generated using <strong>SAF - v0.0.1</strong></span>
        <span>&copy; 2014 VB</span>
      </div>
    </div>"
    body = "
    <body>
      <div class='container'>
        #{@test_summary}
        #{@module_summary}
        #{@details}
        #{footer}
      </div>
      <!-- Modal -->
      <div class='modal fade' id='error-modal' tabindex='-1' role='dialog' aria-labelledby='error-modal-label' aria-hidden='true'>
        <div class='modal-dialog'>
          <div class='modal-content'>
            <div class='modal-header'>
              <button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>
              <h4 class='modal-title text-center' id='myModalLabel'><strong>Error Screen Shot</strong></h4>
            </div>
            <div class='modal-body'>
              <div class='text-center'>
              <img id='modal-image'src='' class='img-responsive'></div>
            </div>
            <div class='modal-footer'>
              <button type='button' class='btn btn-default' data-dismiss='modal'>Close</button>
            </div>
          </div>
        </div>
      </div>
    </body>"
    @f << "<html>#{head}#{body}</html>"
    @f.close
    return @filename
  end

  private
    def test_summary(module_list, test_case_list, test_step_list, status_list)
      status_count = Hash.new(0)
      status_list.each do |status| 
        if status =~ /FAIL/
          status_count["FAIL"] += 1
        else
          status_count[status] += 1
        end
      end
      temp = "
      <div class='page-header'>
        <h1>#{@filename} <small>Test execution report generated on #{Time.new.strftime('%D at %H:%M:%S')}</small></h1>
      </div>"
      
      temp += "
      <!-- Nav tabs -->
      <ul class='nav nav-tabs nav-justified'>
        <li class='active'><a href='#summary' data-toggle='tab'>Summary</a></li>
        <li><a href='#modules' data-toggle='tab'>Modules</a></li>
        <li><a href='#details' data-toggle='tab'>Details</a></li>
      </ul>
      <br>"

      temp += "
      <!-- Tab panes -->
      <div class='tab-content'> 
        <div class='tab-pane active' id='summary'>
          <table class='table table-bordered table-hover'>
            <tr>
              <td class='info'><strong>Filename</strong></td>
              <td>#{@filename}</td>
            </tr>
            <tr>
              <td class='info'><strong>Modules</strong></td>
              <td>#{module_list.count}</td>
            </tr>
            <tr>
              <td class='info'><strong>Tests Executed</strong></td>
              <td>#{test_case_list.count}</td>
            </tr>
            <tr>
              <td class='info'><strong>Tests Steps Executed</strong></td>
              <td>#{test_step_list.count}</td>
            </tr>
            <tr>
              <td class='success'><strong>Passed</strong></td>
              <td>#{status_count['PASS']}</td>
            </tr>
            <tr>
              <td class='danger'><strong>Failed</strong></td>
              <td>#{status_count['FAIL']}</td>
            </tr>
            <tr>
              <td class='warning'><strong>Skipped</strong></td>
              <td>#{status_count['SKIP']}</td>
            </tr>
          </table>
        </div>"
      return temp
    end

    def module_summary(module_hash)
      temp = "
      <div class='tab-pane' id='modules'>
        <table class='table table-bordered table-hover'>
          <thead>
            <tr class='info'>
              <th>Module Name</th>
              <th>Number of Test Cases</th>
              <th>Passed Test Cases</th>
              <th>Failed Test Cases</th>
              <th>Skipped Test Cases</th>
            </tr>
          </thead>"
      status_count = Hash.new(0)
      module_hash.each do |module_name, test_set|
        test_list = []
        current_test = ""
        total_tests = 0
        test_set.each do |test_row|
          if current_test != test_row[1]
            test_status = get_status(test_list) if !test_list.empty?
            status_count[test_status] += 1 if test_status
            total_tests += 1
            current_test = test_row[1]
            test_list = [test_row[3]]
          else
            test_list << test_row[3]
          end
        end
        test_status = get_status(test_list) if !test_list.empty?
        status_count[test_status] += 1 if test_status
        temp += "
        <tr>
          <td>#{module_name.to_s.upcase}</td>
          <td>#{total_tests}</td>
          <td>#{status_count['PASS']}</td>
          <td>#{status_count['FAIL']}</td>
          <td>#{status_count['SKIP']}</td>
        </tr>"
      end
    temp += "</table></div>"
    return temp
    end

    def get_status(test_list)
      if (test_list.grep /^(FAIL)/i) || (test_list.include? "SKIP")
        "FAIL"
      else
        "PASS"
      end
    end
    def details(module_hash)
      temp = "
      <div class='tab-pane' id='details'>
        <div class='panel panel-default'>
          <div class='panel-heading'><strong>Details of Test Execution</strong></div>
          <div class='panel-body'>
            <ul class='nav nav-tabs nav-justified'>
            "
      flag = true
      module_hash.each do |module_name, test_set|
        if flag
          temp += "<li class='active'><a href='##{module_name}' data-toggle='tab'>#{module_name.to_s.upcase}</a></li>"
          flag = false
        else
          temp += "<li><a href='##{module_name}' data-toggle='tab'>#{module_name.to_s.upcase}</a></li>"
        end
      end
      temp += "
      </ul>
      <br>
      <div class='tab-content'>"
      flag = true
      module_hash.each do |module_name, test_row|
        if flag
          temp += "<div class='tab-pane active' id ='#{module_name}'>"
          flag = false
        else
          temp += "<div class='tab-pane' id ='#{module_name}'>"
        end
        temp += "
        <table class='table table-bordered table-hover'>
          <thead>
            <tr class='info'>
              <th>Test Case Name</th>
              <th>Test Step Name</th>
              <th>Status</th>
            </tr>
          </thead>"
        test_row.each do |test|
          case test[3]
            when "PASS"
              temp += "
                <tr class='success'>
                  <td>#{test[1]}</td>
                  <td>#{test[2]}</td>
                  <td>#{test[3]}</td>
                </tr>"
            when "SKIP"
              temp += "
                <tr class='warning'>
                  <td>#{test[1]}</td>
                  <td>#{test[2]}</td>
                  <td>#{test[3]}</td>
                </tr>"
            else
              error_file_path = "./errors/#{@filename}/#{module_name}_#{test[1]}_#{test[2]}.png"
              temp += "
                <tr class='danger'>
                  <td>#{test[1]}</td>
                  <td>#{test[2]}</td>
                  <td><a class='show-modal' href='#{error_file_path}'>#{test[3]}</a></td>
                </tr>"
          end
        end
        temp += "
          </table>
        </div>"
      end
      temp += "
              </div>
            </div>
          </div>
        </div>
      </div>"
      return temp
    end
end