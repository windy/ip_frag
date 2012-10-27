module IPFrag
  class Generator
    def initialize(size, mtu)
      @size = size
      @mtu = mtu
      check_size_mtu
    end
    
    def split_to_ip_packet
      ret = []
      
      offset = 0
      ret << make_ip_packet(@mtu) do |p|
        p.offset = make_offset(offset)
      end
      
      (packet_count - 2).times do
        offset += @mtu
        ret << make_ip_packet(@mtu) do |p|
          p.offset = make_offset(offset)
        end
      end
      
      ret << make_ip_packet(packet_left) do |p|
        p.offset = make_offset(offset, true)
      end
      
      ret
    end
    
    def split_to_ethernet_packet
      ip_packets = split_to_ip_packet
      ip_packets.map do |ip_packet|
        make_ether_packet do |e|
          e.payload = ip_packet
        end
      end
    end
    
    def write_dat(path = '.')
      split_to_ethernet_packet.each_with_index do |p, i|
        file_name = "#{i+1}.dat"
        file = File.open( File.join(path, file_name), 'w') do |f|
          p.write(f)
        end
      end
    end
    
    # Get total packet size, it depends on @size and @mtu
    # 
    #
    def packet_count
      count, left = @size.divmod(@mtu)
      if left != 0
        count += 1
      end
      count
    end
    
    def packet_left
      left = @size % @mtu
      left = @mtu if left == 0
      left
    end
    
    def make_ip_packet(size)
      ip = Mu::Pcap::IPv4.new(src_ip, dst_ip)
      ip.payload = contant(size)
      yield ip if block_given?
      ip
    end
    
    def make_ether_packet
      packet = Mu::Pcap::Ethernet.new(src_mac, dst_mac)
      yield packet
      packet
    end
    
    def make_offset(offset, last = false)
      if offset & (~ 0x07 << 13) != 0x0
        raise "too big offset"
      end
      (1 << 13) & offset
    end
    
    def check_size_mtu
      
      if @size <= @mtu
        raise "Size#{@size} MUST be big than Mtu#{@mtu}."
      end
      
      if @mtu <= 0
        raise "Mtu MUST be an integer big than ZERO"
      end
    end
    
    def src_ip
      @src_ip ||= '200.200.200.1'
    end
    
    def dst_ip
      @dst_ip ||= '200.200.200.2'
    end
    
    def src_mac
      @src_mac ||= '00:00:00:00:00:01'
    end
    
    def dst_mac
      @dst_mac ||= '00:00:00:00:00:02'
    end
    
    attr_writer :src_ip, :dst_ip, :src_mac, :dst_mac
    
    def contant(size)
      'a' * size
    end
  end
  
end