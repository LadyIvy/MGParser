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

#We initialize eventmachine
EventMachine::run do
  		host = UDPSocket.open {|s| s.connect($options.list[:ipaddr]); s.addr.last }
  		port = $options.list[:port]
  		EventMachine::open_datagram_socket host, port, Parser
  		puts "Listening on {host}:{$options.list[:port]}"
	end

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
        puts "Chiamata da parte di: {caller}"
      elsif 
        line =~ /Called Party.*/
        called = line.scan(/Called Party.*'\d.*\d/).first.gsub(/Called Party.* '/,"")
        puts "Verso: {called}"
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
