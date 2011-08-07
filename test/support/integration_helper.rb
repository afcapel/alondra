module PushyResources
  module IntegrationHelper
    def login_as(user)
      visit new_session_path
      fill_in "login", :with => user.username
      fill_in "password", :with => "secret"
      click_button "Log in"
    end

    def log_out
      click_link _('logout')
    end

    def clean_db
      [User, Chat, Message].each { |model| model.delete_all }
    end
  end
end