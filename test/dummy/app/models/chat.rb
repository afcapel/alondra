class Chat < ActiveRecord::Base
  has_many :messages
  push_changes

end
