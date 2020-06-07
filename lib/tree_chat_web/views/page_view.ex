defmodule TreeChatWeb.PageView do
  use TreeChatWeb, :view
  import Earmark
  import Floki
  import HTTPoison
  import Phoenix.HTML

  def decorate_message(body) do
    links = body
    |> Earmark.as_ast
    |> elem(1)
    |> Floki.find("a")

    require IEx; IEx.pry

    body
    |> Earmark.as_html!
    |> raw
  end
end
