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
        |> get_youtube_video_id
        |> compose_preview
    end

    body
    # |> Earmark.as_html!
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

  # def requestOembed(full_url) do
  #   require IEx; IEx.pry
  #   case HTTPoison.get("#{base_url(full_url)}/oembed?url=#{full_url}&format=json") do
  #     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
  #       Jason.decode! body
  #     {:ok, %HTTPoison.Response{status_code: 404}} ->
  #       {:error, "Not found :("}
  #     {:ok, _response = %HTTPoison.Response{}} ->
  #       {:error, "Something other then a 404 or 200"}
  #     {:error, %HTTPoison.Error{reason: _reason}} ->
  #       {:error, "not found"}
  #   end
  # end

  def compose_preview(youtube_video_id) do
    "<br>
      <iframe class='embedded-youtube-video' width='560' height='315'
        src='https://www.youtube.com/embed/#{youtube_video_id}'>
      </iframe>
    "
  end

  def compose_preview(nil) do
    ""
  end

  def append_preview(body, preview) do
    body <> preview
  end

  def get_youtube_video_id(url) do
    case Regex.run(~r/youtube\.com\/watch\?v=([\w-]{11})/, url) do
      nil -> nil
      youtube_string_matches -> List.last(youtube_string_matches)
    end
  end
end
