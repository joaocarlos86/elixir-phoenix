defmodule DiscussWeb.CommentsChannel do
  use DiscussWeb, :channel

  alias Discuss.{Topic, Comment, Repo}

  def join(channel_name, _params, socket) do
    "comments:" <> topic_id = channel_name
    topic_id = String.to_integer(topic_id)

    topic = Topic
      |> Repo.get(topic_id)
      |> Repo.preload(comments: [:user])

    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  def handle_in(_name, message, socket) do
    %{"content" => content} = message
    topic = socket.assigns.topic
    user_id = socket.assigns.user_id

    changeset = topic
    |> Ecto.build_assoc(:comments, user_id: user_id)
    |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        comment = comment
        |> Repo.preload(:user)

        broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", %{comment: comment})
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end


  end
end
