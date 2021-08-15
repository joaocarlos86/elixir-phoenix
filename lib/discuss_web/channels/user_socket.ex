defmodule DiscussWeb.UserSocket do
  use Phoenix.Socket

  channel "comments:*", DiscussWeb.CommentsChannel

  @impl true
  def connect(params, socket, _connect_info) do
    %{"token" => token} = params

    case Phoenix.Token.verify(socket, "key", token) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _error} ->
        :error
    end

  end

  @impl true
  def id(_socket), do: nil
end
