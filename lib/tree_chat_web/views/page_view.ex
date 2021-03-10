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
    |> append_preview(link_preview)
    # |> raw
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

  def compose_preview(nil) do
    ""
  end

  def compose_preview(youtube_video_id) do
    "<br>
      <iframe class='embedded-youtube-video' width='560' height='315'
        src='https://www.youtube.com/embed/#{youtube_video_id}'>
      </iframe>
    "
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
