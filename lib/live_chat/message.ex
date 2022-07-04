defmodule LiveChat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias LiveChat.Repo
  alias __MODULE__
  alias Phoenix.PubSub

  schema "messages" do
    field :message, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message])
    |> validate_required([:name, :message])
    |> validate_length(:message, min: 2)
  end

  @spec create_message(
          :invalid
          | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: :ok | {:error, any}
  def create_message(attrs) do
    %Message{}
    |> changeset(attrs)
    |> Repo.insert()
    |> notify(:message_created)
  end

  def list_messages do
    Message
    |> limit(20)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def subscribe() do
    PubSub.subscribe(LiveChat.PubSub, "live_chat")
  end

  def notify({:ok, message}, event) do
    PubSub.broadcast(LiveChat.PubSub, "live_chat", {event, message})
  end

  def notify({:error, reason}, _event), do: {:error, reason}
end
