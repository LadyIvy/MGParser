#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'eventmachine'
require 'snmp'

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
    


#TODO    
#1 Check for CreateCall and assign call id to 2 variables:
# first is the source id and second the destination id: SourceID DestID
#2 Check e164 parameter in callrouter's Src(CID must correspond to SourceID) and Dst(CID must correspond to DestID) lines to set calling and called number
#3 Check for IID parameter in Callrouter Src with CID corresponding to source id this will help to understand if the call was originated
#  from isdn or sip side
#4 Set FinalDestID = DestID =+ 2 because this will be the final id for destination call and our new reference point for capturing events
#5 When CallManager sends the setup for referred to FinalDestID we can inform user that isdn setup has been sent to the operator or SIP server depending on what kind of source we found in step 3
#6 Check call manager for CallProgress events related to both FinalDestID and SourceID and inform user that call is proceeding (CallProgress are related to "proceeding indication" and "progress indication" )

#TODO
# add option parser:
  # ip of isdn gateway address
  # analyze log instead of gatewy if file is passed
# add EventMachine for remote syslogs from gateway
# each call need to be an istance of new Call class

    
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
