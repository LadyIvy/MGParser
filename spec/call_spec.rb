#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), ".", "../lib"))
require 'call'

describe Call do
  before (:each) do
    @is_file = true
    @call = Call.new
  end
  
  it "should create a new Call instance" do
    @call.should be_true
  end
  
  it "should print called and calling number"
  
  it "should print the cause of the disconnection"
  
  it "should analyze an outbound call which was answered and disconnected by called party" 
    #@call.analyze(data,@is_file)

  it "should analyze an outbound call which was answered and disconnected by calling party"
  
  it "should print notify message for an outbound call which was rejected by called party"
  
  it "should analyze an inbound call which was answered and disconnected by calling party"
  
  it "should analyze an inbound call which was answered and disconnected by called party"
  
end