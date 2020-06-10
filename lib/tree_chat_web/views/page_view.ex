defmodule TreeChatWeb.PageView do
  use TreeChatWeb, :view
  import Earmark
  import Floki
  import HTTPoison
  import Phoenix.HTML
  import Poison.Parser

  def decorate_message(body) do
    links = body
    |> Earmark.as_ast
    |> elem(1)
    |> Floki.find("a")

    # [ {"a", [{"href", "https://www.youtube.com/watch?v=4VcTigzWfeQ"}],["https://www.youtube.com/watch?v=4VcTigzWfeQ"]} ]
    link_preview = case links do
      [] -> ""
      ast_links -> hd(ast_links)
        |> url_from_ast_link
        |> requestOembed
        |> compose_preview
    end

    body
    |> Earmark.as_html!
    |> raw
    # |> link_preview
    # |> append_link_preview(links)
  end

  def url_from_ast_link(ast) do
    case ast do
      {"a", [{"href", url}], _} ->
        url
      _ ->
        nil
    end
  end

  def requestOembed(full_url) do
    case HTTPoison.get("#{base_url(full_url)}/oembed?url=#{full_url}&format=json") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        require IEx; IEx.pry
        Poison.Parser.parse! body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        ""
    end
  end

  def compose_preview(%{title: some_title}) do
    require IEx; IEx.pry
    some_title
    #You left off here, not sure if request oembed works yet6
  end

  def compose_preview(error) do
    error
  end

  def base_url(url) do
    Regex.replace(~r/(?:\/\/)|(\/.*){1}/, url, "")
  end
end
