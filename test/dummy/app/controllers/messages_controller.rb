class MessagesController < ApplicationController
  respond_to :html, :js, :json

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.build(params[:message])

    @message.save

    respond_with @message, :location => @chat
  end
end
