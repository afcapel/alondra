require 'cgi'

module Alondra
  module SessionParser
    extend self

    def verifier
      @verifier ||= ActiveSupport::MessageVerifier.new(Rails.application.config.secret_token)
    end

    def parse(websocket)
      cookie = websocket.request['cookie'] || websocket.request['Cookie']
      token  = websocket.request['query']['token']

      if token.present?
        SessionParser.parse_token(token)
      elsif cookie.present?
        SessionParser.parse_cookie(cookie)
      else
        Hash.new
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
        Hash.new
      rescue Exception => ex
        Rails.logger.error "Exception parsing session from cookie: #{ex.message}"
      end
    end

    def parse_token(token)
      begin
        decoded_token = verifier.verify(token)
        ActiveSupport::JSON.decode(decoded_token)
      rescue ActiveSupport::MessageVerifier::InvalidSignature => ex
        Rails.logger.error "invalid session token: #{token}"
        Hash.new
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