module ChatsHelper

  def present_users
    @present_users = [] #||= Alondra::Channel['/messages/'].users
  end
end
