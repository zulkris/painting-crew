defmodule PaintingCrew.SubmissionsTest do
  use PaintingCrew.DataCase, async: true

  alias PaintingCrew.Submissions
  alias PaintingCrew.Submissions.Submission

  describe "create_submission/1" do
    test "valid attrs creates submission" do
      assert {:ok, %Submission{} = sub} =
               Submissions.create_submission(%{name: "Иван", phone: "+79001234567"})

      assert sub.name == "Иван"
      assert sub.phone == "+79001234567"
      assert sub.source == "landing"
    end

    test "requires name and phone" do
      assert {:error, changeset} = Submissions.create_submission(%{})
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).phone
    end

    test "validates phone format" do
      assert {:error, changeset} =
               Submissions.create_submission(%{name: "Тест", phone: "abc"})

      assert "неверный формат телефона" in errors_on(changeset).phone
    end

    test "validates email format" do
      assert {:error, changeset} =
               Submissions.create_submission(%{name: "Тест", phone: "+79001234567", email: "bad"})

      assert "неверный формат email" in errors_on(changeset).email
    end
  end

  describe "list_submissions/0" do
    test "returns submissions ordered by newest first" do
      {:ok, first} = Submissions.create_submission(%{name: "A", phone: "+79001111111"})
      {:ok, second} = Submissions.create_submission(%{name: "B", phone: "+79002222222"})

      [latest | _] = Submissions.list_submissions()
      assert latest.id == second.id
    end
  end
end
