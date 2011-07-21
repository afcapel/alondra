class Chat < ActiveRecord::Base
  has_many :messages
end
