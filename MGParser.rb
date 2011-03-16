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

module SyslogServer

  def post_init
    puts "Media Gateway is connected!"
  end

  def receive_data(data)
    #calls_hash = Hash.new
    trace = data.gsub(/<191>syslog: /,"")
    trace.each do |line|
    #TODO need to analyze callid of each line in order to print it at starting of each line
      if 
          line =~ /CreateCall.*\d/
          @sourceID, @destID = line.scan(/CreateCall.*\d/).first.gsub(/CreateCall.*create call /,"").split("-")
          #calls_hash['call_with_id' + @sourceID.to_s]=Call.new(@sourceID, @destID)
          #call = Call.new(@sourceID, @destID)
          
      elsif
          line =~ /CallRouter \[.*\] Src=\[CID:\d{1,}/
          src = line.scan(/CallRouter \[.*\] Src=\[CID:\d{1,}/).first.gsub(/CallRouter \[.*\] Src=\[CID:/,"")
          if src == @sourceID
            caller = line.scan(/e164=\d{1,}/).first.gsub(/e164=/,"")
            puts "call_#{@sourceID} - Caller: #{caller}"
          end
      elsif 
          line =~ /CallRouter \[.*\] Dst2\/2=\[CID:\d{1,}/
          dst = line.scan(/CallRouter \[.*\] Dst2\/2=\[CID:\d{1,}/).first.gsub(/CallRouter \[.*\] Dst2\/2=\[CID:/,"")
          if dst == (@destID += 1)
            clled = line.scan(/e164=\d{1,}/).first.gsub(/e164=/,"")
            puts "call_#{@sourceID} - Called: #{called}"
          end
      elsif
         line =~ /CallManager \[.*\] C\d{1,} - Send CallSetupA/
         id = line.scan(/CallManager \[.*\] C\d{1,}/).first.gsub(/CallManager \[.*\] C/,"")
         if id == (@destID += 1)
           puts "call_#{@sourceID} - ISDN setup sent"
         end
      elsif
         line =~ /Received ISDN message "Progress Indication"/
         puts "\"Call Progress\" received, call is proceeding"
      elsif
         line =~ /Received ISDN message "Disconnect Indication"/
         puts "Operator requested hangup"
      elsif
         line =~ /Cause: Normal, unspecified [(]31[)]/
         puts "Called numer is busy!"
      end
  end
    #puts trace
    
  end
end

#We initialize eventmachine
EventMachine::run do
  host = UDPSocket.open {|s| s.connect($options.list[:ipaddr],30000); s.addr.last }
	port = $options.list[:port]
	snmpgw = SnmpGw.new($options.list[:port],$options.list[:ipaddr])
	EventMachine::open_datagram_socket host, port, SyslogServer
end
	
#class Parser
#  def initialize(file)
#    if FileTest::exist?(file)
#      file_lines = IO.readlines(file)
#      analyzer(file_lines)
#    else
#      puts "File non trovato"
#    end
#  end
#  
#  def analyzer(file_lines)
#    file_lines.each do |line|    
#      if 
#        line =~ /Calling Party.*/
#        caller = line.scan(/Calling Party.*'\d.*\d/).first.gsub(/Calling Party.* '/,"")
#        puts "Chiamata da parte di: {caller}"
#      elsif 
#        line =~ /Called Party.*/
#        called = line.scan(/Called Party.*'\d.*\d/).first.gsub(/Called Party.* '/,"")
#        puts "Verso: {called}"
#      elsif
#        line =~ /SEND Setup/
#        puts "Setup ISDN inviato"
#      elsif
#        line =~ /Received ISDN message "Progress Indication"/
#        puts "Ricevuto \"Call Progress\" , l'operatore sta gestendo la chiamata"
#      elsif
#        line =~ /Received ISDN message "Disconnect Indication"/
#        puts "L\'operatore ha richiesto il riaggancio di chiamata"
#      elsif
#        line =~ /Cause: Normal, unspecified [(]31[)]/
#        puts "Il numero chiamato e\' occupato!"
#      end
#    end
#  end
#end

#parser = Parser.new(ARGV.first)
#parser
