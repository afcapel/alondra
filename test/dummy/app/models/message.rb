class Message < ActiveRecord::Base
  belongs_to :chat
  push :changes, :to => :chat
end
