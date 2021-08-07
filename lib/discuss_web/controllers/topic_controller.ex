defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  alias Discuss.Topic

  def new(conn, params) do
    IO.puts("It starts here")
    IO.inspect(conn)
    IO.puts("Params")
    IO.inspect(params)
    IO.puts("Ends here")

    struct = %Topic{} # or Discuss.Topic, without the alias
    params = %{}
    changeset = Topic.changeset(struct, params)

    render conn, "new.html", changeset: changeset
  end
end
