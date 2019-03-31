defmodule IPv4 do
  defstruct header_size: 0, dscp: 0, ecn: 0, total_size: 0, id: 0, flags: 0, frag_offset: 0, 
            ttl: 0, protocol: :tcp, header_checksum: 0, src: 0, dest: 0, options: 0, payload: <<>>

  def parse(<<4::size(4), ihl::size(4), dscp::size(6), ecn::size(2), total_size::binary-size(2),
              id::binary-size(2), flags::size(3), frag_offset::size(13), ttl, protocol,
              header_checksum::binary-size(2), src::binary-size(4), dest::binary-size(4), rest::binary >>)
              when ihl >= 5 do
    header_size = ihl * 4
    options_length = header_size - 20
    << options_data::binary-size(options_length), payload::binary >> = rest

    %IPv4{header_size: header_size, dscp: dscp, ecn: ecn, total_size: total_size, id: id, flags: flags,
          frag_offset: frag_offset, ttl: ttl, protocol: protocol, header_checksum: header_checksum,
          src: src, dest: dest, options: options_data, payload: payload }
  end
end