FactoryGirl.define do
  factory :chat do
    name 'Test chat'
  end

  factory :message do
    association :chat
    text 'Test message'
  end

  sequence :username do |i|
    "user#{i}"
  end

  factory :user do
    username { FactoryGirl.generate(:username) }
    email    { |u| "#{u.username}@example.com" }
    password 'secret'
    password_confirmation 'secret'
  end
end