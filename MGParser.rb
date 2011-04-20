#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), ".", "lib"))
require 'rubygems'
require 'bundler/setup'
require 'eventmachine'
require 'snmp'
require 'optparse'
require 'ostruct'

require 'call'
require 'optparser'
require 'snmp_gw'

$options = Option.parse(ARGV)
$causes = {
           "16" => "Normal hangup (probably requested by the person)", 
           "31" => "Busy",
           "101" =>"Message not compatible with call state"
           }

module SyslogServer

  def post_init
    puts "Media Gateway is connected!"
  end

  def receive_data(data)

    trace = data.gsub(/<191>syslog: /,"")
    @callprogr_counter = 0
    @matched = 0
    
    trace.each do |line|

      if line =~ /Unicast RECV Setup/
        @inbound = true

      elsif line =~ /CallRouter \[.*\] Src=/
        @caller = line.scan(/e164=(\d{1,})/).first          
          
      elsif line =~ /CallRouter \[.*\] Dst\d\/2/
        @called = line.scan(/e164=(\d{1,})/).first

            
      elsif line =~ /UseNextDestination - Call \d{1,}-\d{1,}/
        id = line.scan(/UseNextDestination - Call \d{1,}-(\d{1,})/).first
        if @matched == 1
          puts  "Call ID: #{id} - Caller: #{@caller}"
          puts  "Call ID: #{id} - Called: #{@called}"
          @matched = 0
        end
        if @inbound == true
          @matched += 1
        else
          puts  "Call ID: #{id} - Caller: #{@caller}"
          puts  "Call ID: #{id} - Called: #{@called}"
        end
          
      elsif line =~ /CallManager \[.*\] C\d{1,} - Send CallSetupA/
        id = line.scan(/C(\d{1,})/).first
        if @inbound == true
          puts "Call ID: #{id} - <== ISDN setup received"
        else
          puts "Call ID: #{id} - ==> ISDN setup sent"
        end
        @inbound = false
          
      elsif line =~ /"Proceeding Indication" .* for state CallSetup./
        @progress_indication = true
          
      elsif line =~ /CallManager \[.*\] C\d{1,} - CallProgressA\(2\)/
        @callprogr_counter += 1
        id = line.scan(/C(\d{1,})/).first
          
          if @progress_indication == true
            #puts "Call ID: #{id} - <== \"Proceeding indication\" received from operator" 
            @progress_indication = false
          else
            if @callprogr_counter >= 3
              puts "Call ID: #{id} - <== The call will be probably answered by operator\'s voicemail or is being forwarded"
              @callprogr_counter = 0
            else
              puts "Call ID: #{id} - <== \"Call Progress\" received from operator"
            end
          end 
      
      elsif line =~ /CallManager \[.*\] C\d{1,} - CallProgressA\(3\)/
        id = line.scan(/C(\d{1,})/).first
        puts "Call ID: #{id} - ==> \"Call Progress\" sent to the operator"
          
          
      elsif line =~ /CallManager \[.*\] C\d{1,} - CallProgressA\(1\)/
        id = line.scan(/C(\d{1,})/).first
        puts "Call ID: #{id} - <== Destination number is ringing" 
          
          
      elsif line =~ /CallManager \[.*\] C\d{1,} - CallConnectA/
        id = line.scan(/C(\d{1,})/).first
        puts "Call ID: #{id} - Call has been answered!" 


      elsif line =~ /CallManager \[.*\] C\d{1,} - CallMessageA\(2\)/
        id = line.scan(/C(\d{1,})/).first
        @isdn_inbound_disconnect = true

          
      elsif line =~ /CallManager \[.*\] C\d{1,} - Send CallReleaseA\(\d{1,}\)/
        id = line.scan(/C(\d{1,})/).first
        cause = line.scan(/Send CallReleaseA\((\d{1,})/).first

          if @isdn_inbound_disconnect == true
            puts "Call ID: #{id} - <== Operator requested hangup with cause: \"#{$causes[cause.first]}\""
            @isdn_inbound_disconnect = false
          else
            puts "Call ID: #{id} - ==> Gateway sent hangup with cause: \"#{$causes[cause.first]}\""
          end
          
      end
  end
    
  end
end

#We initialize eventmachine
EventMachine::run do
  host = UDPSocket.open {|s| s.connect($options.list[:ipaddr],30000); s.addr.last }
	port = $options.list[:port]
	snmpgw = SnmpGw.new($options.list[:port],$options.list[:ipaddr],$options.list[:snmp])
	EventMachine::open_datagram_socket host, port, SyslogServer
end
	
	
	
#class Parser
#  def initialize(file)
#    if FileTest::exist?(file)
#      file_lines = IO.readlines(file)
#      analyzer(file_lines)
#    else
#      puts "File not found"
#    end
#  end
#  
#parser = Parser.new(ARGV.first)
#parser
