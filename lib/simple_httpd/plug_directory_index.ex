defmodule SimpleHttpd.PlugDirectoryIndex do
  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case String.last(conn.request_path) do
      "/" -> directory_index(conn)
      _ -> conn
    end
  end

  def directory_index(conn) do
    if File.dir?(conn.assigns.abs_path) do
      create_directory_index(conn)
    else
      conn
    end
  end

  def create_directory_index(conn) do
    out = [
      """
      <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">
      <html>
      <head>
      <title>Index of #{Plug.HTML.html_escape(conn.request_path)}</title>
      </head>
      <body>
      <h1>Index of #{Plug.HTML.html_escape(conn.request_path)}</h1>
      <hr>
      <ul>
      """,
      map_ls(
        conn.assigns.abs_path,
        fn file ->
          abs_path = conn.assigns.abs_path <> "/" <> file
          file_e = Plug.HTML.html_escape(file)

          if File.dir?(abs_path) do
            "<li><a href=\"#{file_e}/\">#{file_e}/</a></li>\n"
          else
            "<li><a href=\"#{file_e}\">#{file_e}</a></li>\n"
          end
        end
      ),
      """
      </ul>
      </body></html>
      """
    ]

    Plug.Conn.put_resp_content_type(conn, "text/html")	# charset=utf-8が付加される
    |> Plug.Conn.resp(200, IO.iodata_to_binary(out))
    |> Plug.Conn.halt()
  end

  def map_ls(path, fun) do
    case File.ls(path) do
      {:ok, list} ->
        Enum.map(
          Enum.sort(list),
          fn file ->
            case file do
              "." <> _ -> []
              _ -> fun.(file)
            end
          end
        )

      _ ->
        []
    end
  end
end
