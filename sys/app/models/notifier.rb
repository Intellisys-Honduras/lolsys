class Notifier < ActionMailer::Base
    def contact(recipient, subject, message, sent_at = Time.now)
      #@user = user
      #email_with_name = "#{@user.name} <#{@user.email}>"
      @subject = subject
      @recipients = recipient
      #@to = email_with_name
      @from = 'intellisys.honduras@gmail.com'
      @sent_on = sent_at
   	  @body = message
      @headers = {}
   end
end

