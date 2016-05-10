defmodule AcceptsGzipTest do
  use ExUnit.Case, async: true
  doctest AcceptsGzip

  test AcceptsGzip do
    data = "{\"name\":\"foo\",\"user_id\":\"1234\"}"
    compressed_data = :zlib.gzip(data)

    # a dummy cowboy conn
    conn = %Plug.Conn{adapter: {Plug.Adapters.Cowboy.Conn,
           {:http_req, "a pid", :ranch_tcp, :keepalive, "a pid", "POST",
            :"HTTP/1.1", {{127, 0, 0, 1}, 62653}, "127.0.0.1", :undefined, 4000,
            "/events", :undefined, "", :undefined, [],
            [{"host", "127.0.0.1:4000"}, {"user-agent", "curl/7.43.0"}, {"accept", "*/*"},
             {"content-type", "application/json"}, {"content-encoding", "gzip"},
             {"content-length", "50"}],
            [], :undefined, [], :waiting,
            compressed_data, :undefined, false, :waiting, [], "", :undefined}},
           req_headers: [{"host", "127.0.0.1:4000"}, {"user-agent", "curl/7.43.0"},
                         {"accept", "*/*"}, {"content-type", "application/json"},
                         {"content-encoding", "gzip"},
                         {"content-length", String.length(compressed_data)}]}
    result = AcceptsGzip.call(conn, [])
    {_, req} = result.adapter

    assert elem(req, 21) == data

    assert(
      req
      |> elem(16)
      |> Enum.find(fn({k,_}) -> k == "content-length" end)
      |> elem(1)
      |> String.to_integer == String.length(data)
    )

    assert(
      req
      |> elem(16)
      |> Enum.find(fn({k,_}) -> k == "raw-payload-size" end)
      |> elem(1)
      |> String.to_integer == String.length(data)
    )

    assert(
      req
      |> elem(16)
      |> Enum.find(fn({k,_}) -> k == "compressed-payload-size" end)
      |> elem(1)
      |> String.to_integer == String.length(compressed_data)
    )
  end
end
