class Call
attr_accessor :data

  def analyze(data,is_file)
 
    @callprogr_counter = 0
    @matched = 0
    
    if is_file == true
      data.each do |line|
        parse(line)
      end
    else
      parse(data)
    end

  end

  def parse(line)
      if line =~ /Unicast RECV Setup/
        @inbound = true

      elsif line =~ /CallRouter \[.*\] Src=/
        @caller = line.scan(/e164=(\d{1,})/).flatten!.first       

      elsif line =~ /CallRouter \[.*\] Dst\d\/2/
        @called = line.scan(/e164=(\d{1,})/).flatten!.first


      elsif line =~ /UseNextDestination - Call \d{1,}-\d{1,}/
        id = line.scan(/UseNextDestination - Call \d{1,}-(\d{1,})/).flatten!.first
        if @matched < 1
          if @inbound == true
            @matched += 1
          else
            puts  "Call ID: #{id} - Caller: #{@caller}"
            puts  "Call ID: #{id} - Called: #{@called}"
          end
        else
          puts  "Call ID: #{id} - Caller: #{@caller}"
          puts  "Call ID: #{id} - Called: #{@called}"
          @matched = 0
        end

      elsif line =~ /CallManager \[.*\] C\d{1,} - Send CallSetupA/
        id = line.scan(/C(\d{1,}) -/).flatten!.first
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
        id = line.scan(/C(\d{1,}) -/).flatten!.first

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
        id = line.scan(/C(\d{1,}) -/).flatten!.first
        puts "Call ID: #{id} - ==> \"Call Progress\" sent to the operator"


      elsif line =~ /CallManager \[.*\] C\d{1,} - CallProgressA\(1\)/
        id = line.scan(/C(\d{1,}) -/).flatten!.first
        puts "Call ID: #{id} - <== Destination number is ringing" 


      elsif line =~ /CallManager \[.*\] C\d{1,} - CallConnectA/
        id = line.scan(/C(\d{1,}) -/).flatten!.first
        puts "Call ID: #{id} - Call has been answered!" 


      elsif line =~ /CallManager \[.*\] C\d{1,} - CallMessageA\(2\)/
        id = line.scan(/C(\d{1,}) -/).flatten!.first
        @isdn_inbound_disconnect = true

      elsif line =~ /CallManager.* Call is not allowed/
        @resource_unavailable = true
        @resource_unavailable_id = line.scan(/CallManager \[.*\] C\d{1,}-(\d{1,})/).flatten!.first


      elsif line =~ /CallManager \[.*\] C\d{1,} - Send CallReleaseA\(\d{1,}\)/
        if @resource_unavailable == true
          id = @resource_unavailable_id
          @resource_unavailable = false
        else
          id = line.scan(/C(\d{1,}) -/).flatten!.first
        end
        cause = line.scan(/Send CallReleaseA\((\d{1,})/).flatten!.first

          if @isdn_inbound_disconnect == true
            puts "Call ID: #{id} - <== Operator requested hangup with cause: \"#{$causes[cause]}\""
            @isdn_inbound_disconnect = false
          else
            puts "Call ID: #{id} - ==> Gateway sent hangup with cause: \"#{$causes[cause]}\""
          end

      end
  end

end
