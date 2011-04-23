MGParser
========

MGParser (MGP) is a tool which makes analysis of Mediatrix ISDN gateways debug a much simpler task.

Prerequisites
=============

- Mediatrix 4400 series media gateway (3000 also should be fine) with firmware version DGW2.0 
- Ruby 1.8.7/1.9.2

Getting Started
=============

Before starting mgparser ensure that there is no firewall enabled on your Mediatrix unit or that there is a rule 
which will accept incoming connections on it's SNMP port (default is 161 but you can provide a different one with -s PORT option).
You can find Mediatrix firewall settings in Network-->Local Firewall menu.
You should also check that the syslog level is set to "Warning" or above for all services, if you have factory default settings
this should already be OK.

To start mgparser just type:
<p><code>
	mgparser -i ip_of_your_Mediatrix_unit
</code></p>

If you want to analyze a log file instead of making live debug you can type:
<p><code>
	mgparser -l path/to/your/log/file
</code></p>
 
<pre><code>
Usage: MGParser.rb [options]

Specific options:
    -p, --port PORT                  Port number on which receive syslog (default is 514)
    -s, --snmpport PORT              Gateway SNMP port number (default is 161)
    -i, --ipaddr IPADDR              Media Gateway IP
    -l, --logfile LOGFILE            Log file to analyze

Common options:
    -h, --help                       Show this message
        --version                    Show version

</code></pre>