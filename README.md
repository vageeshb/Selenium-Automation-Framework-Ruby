Selenium Automation Framework
============================

An automation framework to perform web application testing using Selenium. It reads test scenarios and execution list from data file provided and performs relevant actions.

## Usage ##

### General Guidelines ###
* Main file is 'main.rb'
* Data files will be used from /data/ folder only
* All result reports are created in new folder with start time as folder name in /reports/ folder

### User interface ###
* Run from command line using 'ruby main.rb' in root folder
* Follow instructions

### Command Line Interface ###

Options:

```
-h or --help       : Show command line options
-d [Data File]     : Execute testing with using data from [Data File] in /data/ folder
-e [Email Address] : Email last test result report to [Email Address]
-t                 : Create default data template in /data/ folder (NOTE: Cannot be clubbed with other options)
```

## Roadmap ##

* Provide support for selenium grid usage
* Provide support for object repositories in data file