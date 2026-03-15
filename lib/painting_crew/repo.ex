defmodule PaintingCrew.Repo do
  use Ecto.Repo,
    otp_app: :painting_crew,
    adapter: Ecto.Adapters.Postgres
end
