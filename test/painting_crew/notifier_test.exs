defmodule PaintingCrew.NotifierTest do
  use PaintingCrew.DataCase, async: true

  alias PaintingCrew.Notifier

  test "notify/1 does not crash without config" do
    submission = %PaintingCrew.Submissions.Submission{
      name: "Тест",
      phone: "+79001234567",
      email: "test@example.com",
      source: "landing",
      inserted_at: ~U[2026-03-15 12:00:00Z]
    }

    assert :ok = Notifier.notify(submission)
  end
end
