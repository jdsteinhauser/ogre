defmodule Arp do
  defstruct hw_type: :ethernet, proto_type: :ipv4, hw_len: 6, proto_len: 4, operation: :request, sha: nil, spa: nil, tha: nil, tpa: nil 

  def parse(<< htype :: size(16), proto_type :: size(16), hlen :: size(8), proto_len :: size(8), opcode :: size(16), addrs::binary>>) do
    hlen_octets = hlen * 8
    proto_octets = proto_len * 8
    << sha :: size(hlen_octets), spa :: size(proto_octets), tha :: size(hlen_octets), tpa :: size(proto_octets), _trailer :: binary >> = addrs

    %Arp{
      hw_type: hw_type_to_atom(htype),
      proto_type: proto_type, #TODO: Validate ETH_TYPE when HW_TYPE is 1?
      hw_len: hlen,
      proto_len: proto_len,
      operation: opcode_to_atom(opcode),
      sha: sha,
      spa: spa,
      tha: tha,
      tpa: tpa
    }

  end

  defp opcode_to_atom(1), do: :request
  defp opcode_to_atom(2), do: :reply
  defp opcode_to_atom(_), do: :unknown

  defp hw_type_to_atom(1), do: :ethernet
  defp hw_type_to_atom(_), do: :unknown
end