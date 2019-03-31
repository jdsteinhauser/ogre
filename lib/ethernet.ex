defmodule Ethernet do
@moduledoc """
  Documentation for Ethernet.
  """

  @doc """

  """
    defstruct dest: :empty, src: :empty, eth_type: :na, ieee_802_1q: :empty, length: 0, payload: <<>>, crc: 0

    defp parse_macs(<< dest :: size(48), src :: size(48), rest :: binary >>), do: {:ok, dest, src, rest}

    defp parse_macs(_), do:  {:error, :error_parsing_macs}

    defp parse_eth_type(<< 0x81, 0x00, pcp :: size(3), dei :: size(1), vid :: size(12), eth_type :: size(16), rest :: binary >>) do
        {:ok, eth_type, {pcp, dei, vid}, rest}
    end

    defp parse_eth_type(<< eth_type :: size(16), rest :: binary >>), do: {:ok, eth_type, :empty, rest}

    defp parse_eth_type(_), do: {:error, :invalid_eth_type}

    defp split_payload_crc(data) do
        payload_size = byte_size(data) - 4
        <<payload :: binary-size(payload_size), crc :: binary-size(4) >> = data
        {:ok, payload, crc}
    end

    def validate_crc(_crc), do: :ok

    def parse(packet) do
        with {:ok, dest, src, at_type} <- parse_macs(packet),
             {:ok, eth_type, ieee_802_1_q, payload_and_footer } <- parse_eth_type(at_type),
             {:ok, payload, crc} <- split_payload_crc(payload_and_footer),
             :ok <- validate_crc(crc)
        do
            %Ethernet{dest: dest, src: src, eth_type: eth_type_to_atom(eth_type),
                      ieee_802_1q: ieee_802_1_q, length: byte_size(payload), payload: payload, crc: crc}
        end
    end

    def eth_type_to_atom(eth_type) do
        %{
            ipv4: 0x0800,
            arp:  0x0806,
            wake_on_lan: 0x842,
            ipv6: 0x86dd,
            lldp: 0x88cc
        }
        |> Map.new(fn {k,v} -> {v, k} end)
        |> Map.get(eth_type, :unsupported)
    end
end