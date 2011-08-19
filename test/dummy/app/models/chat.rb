class Chat < ActiveRecord::Base
  has_many :messages
  push :changes

end
