defmodule TreeChatWeb.PageView do
  use TreeChatWeb, :view
  alias TreeChat.Accounts

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
    |> append_preview(link_preview)
    |> raw
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
        {:error, "Not found :("}
      {:ok, response = %HTTPoison.Response{}} ->
        {:error, "Something other then a 404 or 200"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "not found"}
    end
  end

  def compose_preview(%{"title" => title, "html" => html}) do
    html
  end

  def compose_preview({:error, error}) do
    ""
  end

  def compose_preview(response = %{}) do
    ""
  end

  def append_preview(body, preview) do
    body <> preview
  end

  def base_url(url) do
    case Regex.replace(~r/(http(s)?:\/\/)|(\/.*){1}/, url, "") do
      "" -> TreeChatWeb.Endpoint.url
      external_url -> external_url
    end
  end
end
