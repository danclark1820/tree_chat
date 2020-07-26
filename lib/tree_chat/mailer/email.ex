defmodule TreeChat.Email do
  import Bamboo.Email

  def password_reset_email(email, new_password) do
    new_email(
      to: email,
      from: "help@cooler.chat",
      subject: "Your Cooler.Chat password has been reset",
      html_body: "Your password has been reset to <strong>#{new_password}</strong> . You can log in with your new password and once logged in click on \"Account\" in the top right corner to update your password.",
      text_body: "Your password has been reset to #{new_password}.
        You can log in with your new password and click on \"account\" in the top right corner to update your password"
    )
  end
end
