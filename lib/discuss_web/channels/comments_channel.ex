defmodule DiscussWeb.CommentsChannel do
  use Phoenix.Channel

  alias Discuss.{Topic, Comment, Repo}

  def join(channel_name, _params, socket) do
    "comments:" <> topic_id = channel_name
    topic_id = String.to_integer(topic_id)

    topic = Repo.get(Topic, topic_id)

    {:ok, %{}, assign(socket, :topic, topic)}
  end

  def handle_in(_name, message, socket) do
    %{"content" => content} = message
    topic = socket.assigns.topic

    changeset = topic
    |> Ecto.build_assoc(:comments)
    |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, _comment} ->
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end


  end
end
