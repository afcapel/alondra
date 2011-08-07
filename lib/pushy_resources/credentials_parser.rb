module PushyResources
  module CredentialsParser
    extend self

    def verifier
      @verifier ||= ActiveSupport::MessageVerifier.new(Rails.application.config.secret_token)
    end

    def parse(cookie)
      puts "parsing cookie: #{cookie}"
      credentials = {}

      begin
        session_string = CGI.unescape(cookie.split('=').last)
        credentials = verifier.verify(session_string)
      rescue ActiveSupport::MessageVerifier::InvalidSignature => ex
        Rails.logger.error "invalid session cookie: #{cookie}"
      end

      credentials
    end
  end
end