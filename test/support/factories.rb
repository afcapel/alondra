Factory.define :chat do |f|
  f.name 'Test chat'
end

Factory.define :message do |f|
  f.association :chat
  f.text 'Test message'
end

Factory.sequence :username do |i|
  "user#{i}"
end

Factory.define :user do |f|
  f.username { Factory.next(:username) }
  f.email    { |u| "#{u.username}@example.com" }
  f.password 'secret'
  f.password_confirmation 'secret'
end