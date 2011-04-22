#!/usr/bin/env ruby

require 'rubygems'
require 'snmp'
include SNMP

#This object will be used during eventmachine init procedure, it will set the correct ip and port of remote syslog on the gateway
class SnmpGw
attr_accessor :port, :ipaddr, :snmp

def initialize(port, ipaddr, snmp)
  begin
    manager = Manager.new(:Host => ipaddr,:Port => snmp)     
    local_ip = UDPSocket.open {|s| s.connect($options.list[:ipaddr],30001); s.addr.last }
    diagnosticTracesEnable = VarBind.new("1.3.6.1.4.1.4935.1000.100.200.100.1100.1.10000.100.0", SNMP::Integer.new("1"))
    syslogRemoteHost = VarBind.new("1.3.6.1.4.1.4935.1000.100.200.100.1100.1.100.100.0", OctetString.new("#{local_ip}:#{$options.list[:port]}"))
    manager.set(diagnosticTracesEnable)
    manager.set(syslogRemoteHost)
    manager.close
  rescue Errno::EHOSTUNREACH, Errno::EHOSTDOWN
    puts "Host Unreachable!"
    abort ""
  rescue SNMP::RequestTimeout
    puts "Host is not responding (a firewall can be active or there is no SNMP network service listening on port: #{snmp})"
    abort ""
  rescue Interrupt
    puts "Closing gracefully"
  end

end
end
