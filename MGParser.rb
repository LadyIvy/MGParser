#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'eventmachine'
require 'snmp'

=begin
TODO
1 add snmp procedure to enable syslog on media gateway
  -procedure will need ip of gateway as argument
  -it will set syslog server ip and port based on host's ip an default port 514
  -user should be able to provide alternative port
   
2 add EventMachine to manage remote syslog from gateway
  -need to check for host's ip and use it to listen for incoming data on syslog port
  -data should be parsed line by line and output printed to stdout
  -each line should have sourceID and finaldestID as prefix
  -each line will be analyzed in the following way:
    Check for CreateCall, split callid and assign the two values to 2 variables: sourceID and destID
    Check e164 arguments in callrouter to retrieve calling and called numbers (Src(CID must correspond to SourceID) and Dst(CID must correspond to DestID))
    Check IID argument in callrouter's Src (CID must correspond to sourceID) this will help to understand if the call was originated from isdn or sip side
    Calculate finaldestID which will be our new reference point for capturing events (each step in callrouter adds +1 to the original destID)
    When CallManager sends a setup referred to finaldestID we can inform user that isdn setup has been sent to the operator or SIP server depending on what kind of source we found in step 3
    Check call manager for CallProgress events related to both finaldestID and sourceID and inform user that call is proceeding (CallProgress messages are related to both "proceeding indication" and "progress indication" )
  
3 add option parser:
  -ip of isdn gateway address
  -analyze log instead of gatewy if file is passed
=end

class Parser
  def initialize(file)
    if FileTest::exist?(file)
      file_lines = IO.readlines(file)
      analyzer(file_lines)
    else
      puts "File non trovato"
    end
  end
  
  def analyzer(file_lines)
    file_lines.each do |line|    
      if 
        line =~ /Calling Party.*/
        caller = line.scan(/Calling Party.*'\d.*\d/).first.gsub(/Calling Party.* '/,"")
        puts "Chiamata da parte di: #{caller}"
      elsif 
        line =~ /Called Party.*/
        called = line.scan(/Called Party.*'\d.*\d/).first.gsub(/Called Party.* '/,"")
        puts "Verso: #{called}"
      elsif
        line =~ /SEND Setup/
        puts "Setup ISDN inviato"
      elsif
        line =~ /Received ISDN message "Progress Indication"/
        puts "Ricevuto \"Call Progress\" , l'operatore sta gestendo la chiamata"
      elsif
        line =~ /Received ISDN message "Disconnect Indication"/
        puts "L\'operatore ha richiesto il riaggancio di chiamata"
      elsif
        line =~ /Cause: Normal, unspecified [(]31[)]/
        puts "Il numero chiamato e\' occupato!"
      end
    end
  end
end

parser = Parser.new(ARGV.first)
parser
