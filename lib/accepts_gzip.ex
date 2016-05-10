defmodule AcceptsGzip do
  def init(default), do: default
  def call(conn, _opts) do
    if gzip?(conn) do
      adapter = {_, req} = conn.adapter

      raw_request_body = elem(req, 21)
      decompressed_request_body = :zlib.gunzip(raw_request_body)

      headers = elem(req, 16)
      new_headers =
        headers
        |> Enum.reject(fn({k,_}) -> k == "content-length" end)
        |> (&([length_header("raw-payload-size", decompressed_request_body) | &1])).()
        |> (&([length_header("compressed-payload-size", raw_request_body) | &1])).()
        |> (&([length_header("content-length", decompressed_request_body) | &1])).()

      new_req =
        req
        |> update_headers(new_headers)
        |> update_request_body(decompressed_request_body)

      %Plug.Conn{conn | adapter: update_request(adapter, new_req)}
    else
      conn
    end
  end

  defp update_request(adapter, request) do
    put_elem(adapter, 1, request)
  end

  defp update_headers(req, headers) do
    put_elem(req, 16, headers)
  end

  defp update_request_body(req, request_body) do
    put_elem(req, 21, request_body)
  end

  defp length_header(key, payload) do
    {key, payload |> String.length |> to_string}
  end

  defp gzip?(conn) do
    conn
    |> Map.get(:req_headers)
    |> Enum.any?(
    fn({k, v}) ->
      k == "content-encoding" && String.contains?(v, "gzip")
    end)
  end
end
