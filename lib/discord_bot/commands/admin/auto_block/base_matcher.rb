# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class AutoBlock
    module BaseMatcher
      attr_reader :username
      private :username

      def initialize(username)
        @username = username
      end

      def match?
        true
      end
    end
  end
end
