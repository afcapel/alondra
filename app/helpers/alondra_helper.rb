module AlondraHelper
  def encrypted_token
    token = {:user_id => current_user.id, :valid_until => 5.minutes.from_now}.to_json
    Alondra::CredentialsParser.verifier.generate(token)
  end
end