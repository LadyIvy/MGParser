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
$causes = {"16" => "Normal hangup (probably requested by the person)", "31" => "Busy"}

module SyslogServer

  def post_init
    puts "Media Gateway is connected!"
  end

  def receive_data(data)

    trace = data.gsub(/<191>syslog: /,"")
    @callprogr_counter = 0
    trace.each do |line|

    if line =~ /CreateCall.*\d/
        @sourceID, @destID = line.scan(/CreateCall.*\d/).first.gsub(/CreateCall.*create call /,"").split("-")
        @destID = @destID.to_i

    elsif line =~ /CallRouter \[.*\] Src=\[CID:\d{1,}.*speech,date/
        src = line.scan(/CallRouter \[.*\] Src=\[CID:\d{1,}/).first.gsub(/CallRouter \[.*\] Src=\[CID:/,"")
        if src == @sourceID
          caller = line.scan(/e164=\d{1,}/).first.gsub(/e164=/,"")
          puts "Call ID: #{@sourceID} - Caller: #{caller}"
        end
        
    elsif line =~ /CallRouter \[.*\] Dst2\/2=\[CID:\d{1,}/
        dst = line.scan(/CallRouter \[.*\] Dst2\/2=\[CID:\d{1,}/).first.gsub(/CallRouter \[.*\] Dst2\/2=\[CID:/,"")
        if dst.to_i == (@destID += 1)
          called = line.scan(/e164=\d{1,}/).first.gsub(/e164=/,"")
          puts "Call ID: #{@sourceID} - Called: #{called}"
        end
        
    elsif line =~ /CallManager \[.*\] C\d{1,} - Send CallSetupA/
        id = line.scan(/C\d{1,}/).first.gsub(/C/,"")
        if id.to_i == (@destID)
          puts "Call ID: #{@sourceID} - ==> ISDN setup sent"
        end
        
    elsif line =~ /"Proceeding Indication" .* for state CallSetup./
        @progress_indication = true
        
   elsif line =~ /CallManager \[.*\] C\d{1,} - CallProgressA\(2\)/
        @callprogr_counter += 1
        id = line.scan(/C\d{1,}/).first.gsub(/C/,"")
        if id.to_i == (@destID)
          if @progress_indication == true
            puts "Call ID: #{@sourceID} - <== \"Proceeding indication\" received from operator" 
            @progress_indication = false
          else
            if @callprogr_counter >=3 
              puts "Call ID: #{@sourceID} - <== The call will be probably answered by operator\'s voicemail or is being forwarded"
              @callprogr_counter = 0
            else
                puts "Call ID: #{@sourceID} - <== \"Call Progress\" received from operator"
            end
          end 
        end
        
    elsif line =~ /CallManager \[.*\] C\d{1,} - CallProgressA\(1\)/
        id = line.scan(/C\d{1,}/).first.gsub(/C/,"")
        if id.to_i == (@destID)
          puts "Call ID: #{@sourceID} - <== Destination number is ringing" 
        end
        
    elsif line =~ /CallManager \[.*\] C\d{1,} - CallConnectA/
        id = line.scan(/C\d{1,}/).first.gsub(/C/,"")
        if id.to_i == (@destID)
          puts "Call ID: #{@sourceID} - <== Call has been answered!" 
        end
        
    elsif line =~ /CallManager \[.*\] C\d{1,} - CallMessageA\(2\)/
        id = line.scan(/C\d{1,}/).first.gsub(/C/,"")
        if id.to_i == (@destID)
          @isdn_inbound_disconnect = true
        end
          
    elsif line =~ /CallManager \[.*\] C\d{1,} - Send CallReleaseA\(\d{1,}\)/
        id = line.scan(/C\d{1,}/).first.gsub(/C/,"")
        cause = line.scan(/Send CallReleaseA\(\d{1,}/).first.gsub(/Send CallReleaseA\(/,"")
        if id.to_i == (@destID) 
          if @isdn_inbound_disconnect == true
            puts "Call ID: #{@sourceID} - <== Operator requested hangup with cause: \"#{$causes[cause]}\""
            @isdn_inbound_disconnect = false
          else
            puts "Call ID: #{@sourceID} - ==> Gateway sent hangup with cause: \"#{$causes[cause]}\""
          end
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
