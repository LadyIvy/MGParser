#!/usr/bin/env ruby
class Call
  attr_accessor :sourceID, :destID
  #We initialize the class with basic info: ID of the call
  def initialize(sourceID, destID)
    @sourceID = sourceID
    @destID = destID
    #finaldestID should be calculated based on how many steps were made in call router
    @finaldestID = destID 
  end
  
  
end
