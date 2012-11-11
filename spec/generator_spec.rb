require 'spec_helper'
require 'fileutils'

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
    g = IPFrag::Generator.new(100, 8)
    g.split_to_ip_packet.size.should == 13
    g.split_to_ethernet_packet.size.should == 13
  end
  
  it "#write_dat" do
    g = IPFrag::Generator.new(2000, 1460)
    FileUtils.mkdir('tmp')
    g.write_dat('tmp')
    Dir["tmp/*"].size.should == 2
    FileUtils.rm_rf('tmp')
  end
end
