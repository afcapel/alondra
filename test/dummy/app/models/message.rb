class Message < ActiveRecord::Base
  belongs_to :chat
  push_changes

end
