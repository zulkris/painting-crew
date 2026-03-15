defmodule PaintingCrew.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add :name, :string, null: false
      add :phone, :string, null: false
      add :email, :string
      add :source, :string, default: "landing"
      timestamps(type: :utc_datetime)
    end
  end
end
