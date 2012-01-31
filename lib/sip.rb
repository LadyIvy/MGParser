class Sip
  include Mongoid::Document
    
  field :header, :type => Hash
  field :sdp, :type => Hash
end