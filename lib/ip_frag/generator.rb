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
      ret << make_ip_packet(packet_offset) do |p|
        p.offset = make_offset(offset)
        p.payload = udp_offset( contant(udp_size_from(@size), p), 1)
      end
      offset += packet_offset
      
      (packet_count - 2).times do |i|
        ret << make_ip_packet(packet_offset) do |p|
          p.offset = make_offset(offset)
          p.payload = udp_offset( contant(udp_size_from(@size), p), i+2)
        end
        offset += packet_offset
      end
      
      ret << make_ip_packet(packet_left) do |p|
        p.offset = make_offset(offset, true)
        p.payload = udp_offset( contant(udp_size_from(@size), p), packet_count)
      end
      
      ret
    end
    
    def split_to_ethernet_packet
      ip_packets = split_to_ip_packet
      ip_packets.map do |ip_packet|
        make_ether_packet do |e|
          e.payload = ip_packet
          e.type
        end
      end
    end
    
    def write_dat(path = '.')
      split_to_ethernet_packet.each_with_index do |p, i|
        file_name = "#{i+1}.dat"
        file = File.open( File.join(path, file_name), 'wb') do |f|
          p.write(f)
        end
      end
    end
    
    # Get total packet size, it depends on @size and @mtu
    # 
    #
    def packet_count
      count, left = @size.divmod(packet_offset)
      if left != 0
        count += 1
      end
      count
    end
    
    def packet_offset
      @mtu & (~7)
    end
    
    def packet_left
      left = @size % packet_offset
      left = packet_offset if left == 0
      left
    end
    
    def make_ip_packet(size)
      ip = Mu::Pcap::IPv4.new(src_ip, dst_ip)
      ip.proto = Mu::Pcap::IP::IPPROTO_UDP
      yield ip if block_given?
      ip
    end
    
    def make_ether_packet
      packet = Mu::Pcap::Ethernet.new(src_mac, dst_mac)
      packet.type = Mu::Pcap::Ethernet::ETHERTYPE_IP
      yield packet
      packet
    end
    
    def make_offset(offset, last = false)
      offset = offset >> 3
      
      flag = 1
      if last
        flag = 0
      end
      ( flag << 13) | offset
    end
    
    def check_size_mtu
      
      if @size <= @mtu
        raise "Size #{@size} MUST be big than Mtu #{@mtu}."
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
    
    def src_port
      @src_port ||= 1000
    end
    
    def dst_port
      @dst_port ||= 2000
    end
    
    
    attr_writer :src_ip, :dst_ip, :src_mac, :dst_mac, :src_port, :dst_port
    
    def udp_offset( udp, packet_num)
      size = @mtu
      udp[(packet_num-1)*size..packet_num*size -1 ]
    end
    
    def udp_size_from(ip_size)
      ip_size - 8
    end
    
    
    # 生成特定长度的 UDP 报文
    def contant(size, ip)
      return @udp_packet if @udp_packet
      udp = Mu::Pcap::UDP.new(src_port, dst_port)
      udp.payload = 'a' * size
      udp_packet_str = StringIO.new
      udp.write(udp_packet_str, ip)
      udp_packet_str.rewind
      @udp_packet ||= udp_packet_str.read
    end
  end
  
end