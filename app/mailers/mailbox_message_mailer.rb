class MailboxMessageMailer < ApplicationMailer
	def new_message_email(message,receiver)
	  @message  = message
	  @receiver = receiver
	  #set_subject(message)
	  mail :to => receiver.send(Mailboxer.email_method, message),
	       :subject => "#{message.sender.name} has sent you a message",
	       :template_name => 'new_message_email'
	end

	def reply_message_email(message,receiver)
	  @message  = message
	  @receiver = receiver
	  #set_subject(message)
	  mail :to => receiver.send(Mailboxer.email_method, message),
	       :subject => "#{message.sender.name} has replied",
	       :template_name => 'reply_message_email'
	end

	def send_email(message, receiver)
	  if message.conversation.messages.size > 1
	    reply_message_email(message,receiver)
	  else
	    new_message_email(message,receiver)
	  end
	end
end
