defmodule PaintingCrew.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "submissions" do
    field :name, :string
    field :phone, :string
    field :email, :string
    field :source, :string, default: "landing"
    timestamps(type: :utc_datetime)
  end

  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:name, :phone, :email, :source])
    |> validate_required([:name, :phone])
    |> validate_format(:phone, ~r/^\+?[\d\s\-\(\)]{7,}$/, message: "неверный формат телефона")
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "неверный формат email")
  end
end
