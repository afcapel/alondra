require 'cgi'

module Alondra
  module SessionParser
    extend self

    def verifier
      @verifier ||= ActiveSupport::MessageVerifier.new(Rails.application.config.secret_token)
    end

    def parse(websocket)
      if websocket.request['query']['token'].present?
        token = websocket.request['query']['token']
        SessionParser.parse_token(token)
      else
        cookie = websocket.request['cookie'] || websocket.request['Cookie']
        SessionParser.parse_cookie(cookie)
      end
    end

    def parse_cookie(cookie)
      begin
        cookies = cookie.split(';')
        session_key = Rails.application.config.session_options[:key]

        encoded_session = cookies.detect{|c| c.include?(session_key)}.gsub("#{session_key}=",'').strip
        verifier.verify(CGI.unescape(encoded_session))
      rescue ActiveSupport::MessageVerifier::InvalidSignature => ex
        Rails.logger.error "invalid session cookie: #{cookie}"
        {}
      end
    end

    def parse_token(token)
      begin
        decoded_token = verifier.verify(token)
        ActiveSupport::JSON.decode(decoded_token)
      rescue ActiveSupport::MessageVerifier::InvalidSignature => ex
        Rails.logger.error "invalid session token: #{token}"
        {}
      end
    end

    def session_key
      Rails.application.config.session_options.key
    end

    def marshall
      Rails.application.config.session_options[:coder]
    end
  end
end