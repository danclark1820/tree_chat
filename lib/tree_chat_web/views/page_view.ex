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
    |> Earmark.as_html!
    |> append_preview(link_preview)
  end

  def reply_count_and_spans(replies, message) do
    {reply_count_acc, reply_span_acc} = Enum.reduce(replies, {0, ""}, fn reply, {count_acc, span_acc} ->
      case reply.reply_id == message.id do
        true ->
          {count_acc + 1, span_acc <> "<span class='message-reply reply-message-#{message.id} data-reply-messge-id=#{message.id}' data-reply-name='#{reply.name}' data-reply-id='#{reply.id}' data-reply-body='#{decorate_message(reply.body)}'></span>"}
        false ->
          {count_acc, span_acc}
      end
    end)
    {reply_count_acc, reply_span_acc}
  end

  def url_from_ast_link(ast) do
    case ast do
      {"a", [{"href", url}], _} ->
        url
      _ ->
        nil
    end
  end

  def compose_preview({:no_link, nil}) do
    ""
  end

  def compose_preview({:youtube, youtube_video_id}) do
    "
      <iframe class='embedded-youtube-video' width='560' height='315'
        src='https://www.youtube.com/embed/#{youtube_video_id}'>
      </iframe>
    "
  end

  def compose_preview({:instagram, instagram_path_w_id}) do
    "
      <iframe class='embedded-instagram' width='560' height='690'
        src=\"https://www.instagram.com/#{instagram_path_w_id}/embed\">
      </iframe>
    "
  end

  def append_preview(body, preview) do
    body <> preview
  end

  def get_youtube_video_id(url) do
    cond do
      Regex.run(~r/youtube\.com\/watch\?v=([\w-]{11})/, url) ->
        {:youtube, List.last(Regex.run(~r/youtube\.com\/watch\?v=([\w-]{11})/, url))}
      Regex.run(~r/https:\/\/www.instagram.com\/(.*\/[\w-]{11})/, url) ->
        {:instagram, List.last(Regex.run(~r/https:\/\/www.instagram.com\/(.*\/[\w-]{11})/, url))}
      true -> {:no_link, nil}
    end
  end
end
