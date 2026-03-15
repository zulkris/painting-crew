defmodule PaintingCrew.Repo do
  use Ecto.Repo,
    otp_app: :painting_crew,
    adapter: Ecto.Adapters.SQLite3
end
