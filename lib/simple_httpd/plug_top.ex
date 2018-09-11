defmodule SimpleHttpd.PlugTop do
  def init(opts) do
    opts
  end

  defp set_path_params(conn, app) do
    app_env = Application.get_all_env(app)
    doc_root = Keyword.get(app_env, :document_root)
    path = conn.request_path |> Path.expand()
    path_info = :binary.split(path, "/", [:global]) |> tl()
    abs_path = doc_root <> path

    Plug.Conn.merge_assigns(conn,
      app_env: app_env,
      doc_root: doc_root,
      path: path,
      path_info: path_info,
      abs_path: abs_path
    )
  end

  def call(conn, [app: app]) do
    conn = set_path_params(conn, app)

    try do
      conn = Plug.Logger.call(conn, :debug)
      if conn.halted, do: throw(conn)

      conn = SimpleHttpd.PlugPathCheck.call(conn, [])
      if conn.halted, do: throw(conn)

      conn = SimpleHttpd.PlugDirectoryPortal.call(conn, [])
      if conn.halted, do: throw(conn)

      conn = SimpleHttpd.PlugDirectoryIndex.call(conn, [])
      if conn.halted, do: throw(conn)

      opts = Plug.Static.init(at: "", from: conn.assigns.doc_root)
      conn = Plug.Static.call(conn, opts)
      if conn.halted, do: throw(conn)

      conn = SimpleHttpd.PlugNotFound.call(conn, [])
      conn
    catch
      conn -> conn
    end
  end
end
