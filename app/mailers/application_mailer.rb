class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@cocociti.com"
  default bcc: "hello@cocociti.com,j@cocociti.com,t@cocociti.com"
  layout 'mailer'
end
