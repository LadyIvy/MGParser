class Call
attr_accessor :data

  # "analyze" will choose how to process syslog with "parse method" 
  
  def self.analyze_sip
    data = Pcap::Capture.open_offline($options.list[:logfile])
      data.each_packet do |pkt|
        sip = Sip.new
        sip.header = {}
        sip.sdp = {}
        #(?:^Via)?:
    	  pkt.udp_data.scan(/(^.*): (.*)$/) do |field, value| 
    	    case field
  	      when "Via"
    	      sip.header[:via] = "#{value}"
  	      when "From"
  	        sip.header[:from] = "#{value}"
  	      when "To"
  	        sip.header[:to] = "#{value}"
  	      when "Contact"
  	        sip.header[:contact] = "#{value}"
  	      when "Call-ID"
  	        sip.header[:call_id] = "#{value}"
  	      when "CSeq"
  	        sip.header[:cseq] = "#{value}"
  	      end
    	  end
    	  sip.save
    end
  end  
   
  def analyze(data,is_file)
     
    if is_file == true
      data.each do |line|
        parse(line)
      end
    else
      parse(data)
    end

  end

  # parse method will parse each line of incoming syslog and print filtered content
  
  def parse(line)
    
      # we check for call inizialization message and set:
      # @id = call id number (this will help to understand which call are the messages related to)
      # @direction = is needed to determine if the call is inbound or outbound
      # @content = is the content of the DSS1 message
      
      if line =~ /IsdnStackL3Msg.*Call \d{1,}-(In|Out)bound/
        @id, @direction, @content = line.scan(/IsdnStackL3Msg.*Call (\d{1,})-.*(RECV|SEND) (\w{1,}.*) \(/).flatten!
        
        #we print message based on @direction (if the message content is "Notify" don't do anything
        # and wait for "Notification Indicator" message instead because it contains notification description )
        
        if @direction == "SEND" and @content != "Disconnect" and @content != "Release"
          puts "Call #{@id} - ==> Sent \"#{@content}\""
        elsif @direction == "RECV" and @content == "Notify"
          nil
        elsif @direction == "RECV" and @content != "Disconnect" and @content != "Release"
          puts "Call #{@id} - <== Received \"#{@content}\""
        end
      
      # here we check for caller and called numbers 
        
      elsif line =~ /IsdnStackL3Msg.*IE (Called|Calling) Party Number/
        origin, number = line.scan(/IsdnStackL3Msg.*IE (Called|Calling) Party Number.*'(\d{1,})'/).flatten!
        if origin == "Called"
          puts "Call #{@id} - Called number: #{number}"
        elsif origin == "Calling"
          puts "Call #{@id} - Calling number: #{number}"
        end
      
      # we print notification messages description
        
      elsif line =~ /IsdnStackL3Msg.*IE Notification Indicator/
        notification = line.scan(/IsdnStackL3Msg.*IE Notification Indicator.*Description: (.*) \(/).flatten!.first
        puts "Call #{@id} - <== Received Notify: \"#{notification}\" (if you called a mobile number it could be the VoiceMail)"
      
      # it will print call disconnection cause
      
      elsif line =~ /IsdnStackL3Msg.*IE Cause/
          cause = line.scan(/IsdnStackL3Msg.*IE Cause.* Cause.*\((.*)\)/).flatten!.first
          if @direction == "RECV"
            puts "Call #{@id} - <== Received \"#{@content}\" with cause: \"#{$causes[cause]}\""
          elsif @direction == "SEND"
            puts "Call #{@id} - ==> Sent \"#{@content}\" with cause: \"#{$causes[cause]}\""
          end
      end
  end #parse
end # Call