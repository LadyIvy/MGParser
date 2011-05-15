class Call
attr_accessor :data

  def analyze(data,is_file)
     
    if is_file == true
      data.each do |line|
        parse(line)
      end
    else
      parse(data)
    end

  end

  def parse(line)
      if line =~ /IsdnStackL3Msg.*Call \d{1,}-(In|Out)bound/
        @id, @direction, @content = line.scan(/IsdnStackL3Msg.*Call (\d{1,})-.*(RECV|SEND) (\w{1,}.*) \(/).flatten!
        
        if @direction == "SEND" and @content != "Disconnect" and @content != "Release"
          puts "Call #{@id} - ==> Sent \"#{@content}\""
        elsif @direction == "RECV" and @content == "Notify"
          nil
        elsif @direction == "RECV" and @content != "Disconnect" and @content != "Release"
          puts "Call #{@id} - <== Received \"#{@content}\""
        end
        
      elsif line =~ /IsdnStackL3Msg.*IE (Called|Calling) Party Number/
        origin, number = line.scan(/IsdnStackL3Msg.*IE (Called|Calling) Party Number.*'(\d{1,})'/).flatten!
        if origin == "Called"
          puts "Call #{@id} - Called number: #{number}"
        elsif origin == "Calling"
          puts "Call #{@id} - Calling number: #{number}"
        end
        
      elsif line =~ /IsdnStackL3Msg.*IE Notification Indicator/
        notification = line.scan(/IsdnStackL3Msg.*IE Notification Indicator.*Description: (.*) \(/).flatten!.first
        puts "Call #{@id} - <== Received Notify: \"#{notification}\" (if you called a mobile number it could be the VoiceMail)"
      
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