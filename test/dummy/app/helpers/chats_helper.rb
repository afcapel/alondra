module ChatsHelper

  def present_users
    @present_users = [] #||= PushyResources::Channel['/messages/'].users
  end
end
