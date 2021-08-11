defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  alias Discuss.{Topic, Repo}
  alias DiscussWeb.Router.Helpers

  plug DiscussWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  plug :check_post_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render conn, "index.html", topics: topics
  end

  def new(conn, _params) do
    struct = %Topic{} # or Discuss.Topic, without the alias
    params = %{}
    changeset = Topic.changeset(struct, params)

    render conn, "new.html", changeset: changeset
  end

  def create(conn, params) do
    %{"topic" => topic} = params

    changeset = conn.assigns[:user]
    |> Ecto.build_assoc(:topics)
    |> Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Topic created")
        |> redirect(to: Routes.topic_path(conn, :index))
      {:error, changeset} -> render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, params) do
    %{"id" => topic_id} = params
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic, %{})

    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, params) do
    %{"id" => topic_id, "topic" => topic} = params
    old_topic =  Repo.get(Topic, topic_id)
    changeset = old_topic
    |> Topic.changeset(topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated")
        |> redirect(to: Routes.topic_path(conn, :index))
      {:error, changeset} -> render conn, "edit.html", changeset: changeset, topic: old_topic
    end
  end

  def delete(conn, params) do
    %{"id" => topic_id} = params
    Repo.get!(Topic, topic_id)
    |> Repo.delete!

    conn
    |> put_flash(:info, "Topic deleted")
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  def check_post_owner(conn, _paramsFromPlug) do
    %{params: %{"id" => topic_id}} = conn

    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You cannot modify this topic")
      |> redirect(to: Helpers.topic_path(conn, :index))
      |> halt()
    end

    if conn.assigns[:user] do
      conn

    end
  end
end
