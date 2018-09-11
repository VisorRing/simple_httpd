defmodule SimpleHttpd.PlugNotFound do
  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    Plug.Conn.put_resp_content_type(conn, "text/html")	# charset=utf-8が付加される
    |> Plug.Conn.send_resp(404, """
    <!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">
    <html><head>
    <title>404 Not Found</title>
    </head><body>
    <h1>Not Found</h1>
    <p>The requested URL #{Plug.HTML.html_escape(conn.request_path)} was not found on this server.</p>
    </body></html>
    """)
    |> Plug.Conn.halt()
  end
end
