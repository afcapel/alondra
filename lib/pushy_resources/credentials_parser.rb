module PushyResources
  module CredentialsParser
    extend self

    def verifier
      @verifier ||= ActiveSupport::MessageVerifier.new(Rails.application.config.secret_token)
    end

    def parse(token)
      credentials = {}
      begin
        decoded_token = verifier.verify(token)
        credentials   = ActiveSupport::JSON.decode(decoded_token)
      rescue ActiveSupport::MessageVerifier::InvalidSignature => ex
        Rails.logger.error "invalid session cookie: #{cookie}"
      end

      credentials
    end
  end
end