defmodule PaintingCrew.Notifier do
  import Swoosh.Email
  alias PaintingCrew.Mailer

  require Logger

  def notify(submission) do
    send_email(submission)
    send_telegram(submission)
    :ok
  end

  defp send_email(submission) do
    config = Application.get_env(:painting_crew, __MODULE__, [])
    from = config[:from] || "noreply@example.com"
    to = config[:to]

    if to do
      new()
      |> from({"Покрасочная бригада", from})
      |> to(to)
      |> subject("Новая заявка: #{submission.name}")
      |> text_body(email_body(submission))
      |> Mailer.deliver()
    else
      Logger.info("Notifier: email skipped (no :to configured)")
    end
  end

  defp send_telegram(submission) do
    config = Application.get_env(:painting_crew, __MODULE__, [])
    token = config[:telegram_bot_token]
    chat_id = config[:telegram_chat_id]

    if token && chat_id do
      url = "https://api.telegram.org/bot#{token}/sendMessage"

      body = %{
        chat_id: chat_id,
        text: telegram_text(submission),
        parse_mode: "HTML"
      }

      case Req.post(url, json: body) do
        {:ok, %{status: 200}} -> :ok
        {:ok, resp} -> Logger.warning("Telegram API error: #{inspect(resp.status)}")
        {:error, err} -> Logger.warning("Telegram request failed: #{inspect(err)}")
      end
    else
      Logger.info("Notifier: telegram skipped (no token/chat_id configured)")
    end
  end

  defp email_body(submission) do
    """
    Новая заявка с сайта

    Имя: #{submission.name}
    Телефон: #{submission.phone}
    Email: #{submission.email || "—"}
    Источник: #{submission.source}
    Дата: #{Calendar.strftime(submission.inserted_at, "%d.%m.%Y %H:%M")}
    """
  end

  defp telegram_text(submission) do
    """
    <b>Новая заявка</b>

    Имя: #{submission.name}
    Телефон: #{submission.phone}
    Email: #{submission.email || "—"}
    Источник: #{submission.source}
    """
  end
end
