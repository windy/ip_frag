require 'spec_helper'

describe IPFrag do
  it "show version" do
    lambda { IPFrag::VERSION }.should_not raise_error
  end
  
  it "#check_size_mtu" do
    lambda { IPFrag::Generator.new(100, 10) }.should_not raise_error
    lambda { IPFrag::Generator.new(100, 0) }.should raise_error
    lambda { IPFrag::Generator.new(10, 10) }.should raise_error
    lambda { IPFrag::Generator.new(10, -1) }.should raise_error
  end
  
  it "#split" do
    g = IPFrag::Generator.new(100, 10)
    g.split_to_ip_packet.size.should == 10
    g.split_to_ethernet_packet.size.should == 10
  end
  
  it "#write_dat" do
    g = IPFrag::Generator.new(100, 10)
    g.write_dat('helper')
  end
end
