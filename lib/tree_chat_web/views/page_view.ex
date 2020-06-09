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

    body
    |> Earmark.as_html!
    |> raw
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
        Poison.Parser.parse! body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def compose_preview(ombed_json) do
    #You left off here, not sure if request oembed works yet
  end

  def base_url(url)
    Regex.replace(~r/(?:\/\/)|(\/.*){1}/, url, "")
  end
end
