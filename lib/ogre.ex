defmodule Ogre do
  @moduledoc """
  Documentation for Ogre.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Ogre.hello
      :world

  """
  def hello do
    Stream.resource(
      fn -> elem(:epcap.start, 1) end,
      fn pid ->
        receive do
          {:packet, _eth, _time, _len, data} -> {[data], pid}
          _ -> {:halt, pid}
        end
      end,
      fn pid -> :epcap.stop(pid) end)
  end
end
