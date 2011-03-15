#!/usr/bin/env ruby
  class Option

    #
    # Return a structure describing the options.
    #
    def self.parse(args)
      
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = OpenStruct.new
      #A hash containing all command-line arguments with some default values
      options.list = {:port =>"514"}
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

        # Boolean switch.
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options.verbose = v
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
          puts OptionParser::Version.join('.')
          exit
        end
      end

      opts.parse!(args)
      options
    end  # parse()

  end  # class OptparseExample