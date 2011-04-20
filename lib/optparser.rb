#!/usr/bin/env ruby
require "version"

  class Option
    
    #
    # Return a structure describing the options.
    #
    def self.parse(args)
      
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = OpenStruct.new
      #A hash containing all command-line arguments with some default values
      options.list = {:port =>"514", :snmp => "161"}
      options.verbose = false

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: MGParser.rb [options]"

        opts.separator ""
        opts.separator "Specific options:"
        
        
        #Syslog port number
        opts.on("-p", "--port PORT",
                "Port number on which receive syslog (default is 514)") do |port|
          options.list[:port] = port
        end
        
        #Gateway SNMP port number
        opts.on("-s", "--snmpport PORT",
                "Gateway SNMP port number (default is 161)") do |snmp|
          options.list[:snmp] = snmp
        end
        
        #gateway's ip address
        opts.on("-i", "--ipaddr IPADDR",
                "Media Gateway IP") do |ipaddr|
          options.list[:ipaddr] = ipaddr
        end
        
        #log file
        opts.on("-l", "--logfile LOGFILE",
                "Log file to analyze") do |logfile|
          options.list[:logfile] = logfile
        end


        opts.separator ""
        opts.separator "Common options:"

        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        # Another typical switch to print the version.
        opts.on_tail("--version", "Show version") do
          puts Mgparser::VERSION::STRING
          exit
        end
      end

      opts.parse!(args)
      options
    end  # parse()

  end  # class OptparseExample
