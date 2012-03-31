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
describe ApplicationHelper do
  describe "title" do
    before(:each) do
      @test_base_title = "Cyro Laughs (@cyrolaughs)"
    end
    it "should return base_title without @title" do
      helper.title.should == @test_base_title
    end
    
    it "should return 'C' plus base title with @title" do
      @title = "C"
      helper.title.should == "C | #{@test_base_title}"
    end
  end
end
