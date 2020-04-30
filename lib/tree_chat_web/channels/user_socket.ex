defmodule TreeChatWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "room:*", TreeChatWeb.RoomChannel
  channel "water_cooler:*", TreeChatWeb.WaterCoolerChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  def connect(%{"token" => token}, socket, _connect_info) do
    # max_age: 1209600 is equivalent to two weeks in seconds
    case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
      {:ok, user_id} ->
        # This is not getting set or is not available for some reason
        # We should really be getting the user from the socket and not the window
        # This should always be getting hit once a user has a token
        # We have a token and we are literally not using it.
        # This is getting set on the socket and is only avialbe in the
        # context of a channel.
        {:ok, assign(socket, :user, "PIZZA MESSAGE CHICKEN PARM HIT")}
      {:error, reason} ->
        {:ok, socket}
        # {:error, "Could not connect to socket: #{reason}"}
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     TreeChatWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
