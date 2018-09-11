defmodule SimpleHttpd.PlugDirectoryPortal do
  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case String.last(conn.request_path) do
      "/" -> directory_portal(conn)
      _ -> conn
    end
  end

  def directory_portal(conn) do
    index_files = Keyword.get(conn.assigns.app_env, :directory_index)

    case Enum.find(index_files, nil, fn file ->
           File.regular?(conn.assigns.abs_path <> "/" <> file)
         end) do
      nil ->
        conn

      file ->
        %{conn | path_info: conn.path_info ++ [file], request_path: conn.request_path <> file}
        |> Plug.Static.call(Plug.Static.init(at: "", from: conn.assigns.doc_root))
    end
  end
end
