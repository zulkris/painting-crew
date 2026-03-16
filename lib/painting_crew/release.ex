defmodule PaintingCrew.Release do
  @app :painting_crew

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn repo ->
        case Ecto.Adapters.SQLite3.storage_up(repo.config()) do
          :ok -> :ok
          {:error, :already_up} -> :ok
        end
        Ecto.Migrator.run(repo, :up, all: true)
      end)
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
