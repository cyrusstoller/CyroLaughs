require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the PagesHelper. For example:
#
# describe PagesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe PagesHelper do
  describe "humanize time" do
    it "should return 0:00 if 0 seconds" do
      helper.humanize_time(0).should == "00:00"
    end
    
    it "should return time when less than a minute" do
      helper.humanize_time(30).should == "00:30"
    end
    
    it "should return time when less than 10 minutes" do
      helper.humanize_time(301).should == "05:01"
    end
    
    it "should return time when more than 10 minutes" do
      helper.humanize_time(601).should == "10:01"
    end
    
    it "should return time when more than 1 hour" do
      helper.humanize_time(3663).should == "01:01:03"
    end
  end
end
