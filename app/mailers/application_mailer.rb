class ApplicationMailer < ActionMailer::Base
  default from: Settings.default.email_from
  layout "mailer"
end
