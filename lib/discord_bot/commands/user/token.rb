# frozen_string_literal: true

module DiscordBot::Commands::User
  class Token
    attr_reader :user, :wiki_user
    private :user, :wiki_user

    def initialize(user:, wiki_user:)
      @user = user
      @wiki_user = wiki_user
    end

    def code
      totp.at(0)
    end

    def verify(candidate)
      totp.verify(candidate, 0)
    end

    private

    def totp
      @totp ||= ROTP::HOTP.new(secret)
    end

    def secret
      Base32.encode("#{user.id}-#{wiki_user}")
    end
  end
end
