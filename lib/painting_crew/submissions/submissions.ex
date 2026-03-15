defmodule PaintingCrew.Submissions do
  import Ecto.Query
  alias PaintingCrew.Repo
  alias PaintingCrew.Submissions.Submission

  def list_submissions do
    Submission
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create_submission(attrs) do
    %Submission{}
    |> Submission.changeset(attrs)
    |> Repo.insert()
  end

  def change_submission(%Submission{} = submission, attrs \\ %{}) do
    Submission.changeset(submission, attrs)
  end
end
