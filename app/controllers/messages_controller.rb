class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_transaction, only: [:show, :reply]
  def index
    @conversations = current_user.mailbox.inbox
  end

  def show
    @messages = @conversation.messages.order(:created_at) if @conversation
  end

  def destroy
    c = Mailboxer::Conversation.find params[:id]
    current_user.mark_as_deleted c
    redirect_to messages_path
  end

  def reply
    current_user.reply_to_conversation(@conversation, params[:message])
    redirect_to message_path(@transaction)
  end

  private
  def set_transaction
    @transaction = Transaction.find params[:id]
    @conversation = @transaction.mailbox.inbox.first
    unless @transaction.user == current_user || @transaction.seller == current_user
      redirect_to messages_path
    end
  end
end