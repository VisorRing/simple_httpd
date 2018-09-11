
defmodule SimpleHttpd.PlugPathCheck do
  @moduledoc """
  A Plug to check if access to the directory is ended with slash.
  """

  def init(opt) do
    opt
  end

  def call(conn, _opts) do
    case String.last(conn.request_path) do
      "/" ->
        conn

      _ ->
        if File.dir?(conn.assigns.abs_path) do
          reply_moved_perm(conn, conn.assigns.path <> "/")
        else
          conn
        end
    end
  end

  def reply_moved_perm(conn, newpath) do
    url = make_url(conn.scheme, conn.host, conn.port, newpath, conn.query_string)
    Plug.Conn.put_resp_content_type(conn, "text/html")	# charset=utf-8が付加される
    |> Plug.Conn.put_resp_header("location", url)
    |> Plug.Conn.resp(301, """
    <!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">
    <html><head>
    <title>301 Moved Permanently</title>
    </head><body>
    <h1>Moved Permanently</h1>
    <p>The document has moved <a href=\"#{Plug.HTML.html_escape(url)}\">here</a>.</p>
    </body></html>
    """)
    |> Plug.Conn.halt()
  end

  def make_url(scheme, host, port, path, query) do
    # pathはOSパス、未エンコードのもの
    # queryはエンコード済みのもの
    to_string(scheme) <>
      "://" <>
      URI.encode(host) <>
      case scheme do
        :http -> if(port == 80, do: "", else: ":" <> to_string(port))
        :https -> if(port == 443, do: "", else: ":" <> to_string(port))
      end <> URI.encode(path) <> if(query && query != "", do: "?" <> query, else: "")
  end
end
