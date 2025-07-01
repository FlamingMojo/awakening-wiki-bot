# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class AutoBlock
    class ManualBlacklistedName
      attr_reader :username
      private :username

      def initialize(username)
        @username = username
      end

      def match?
        # Simply put, if a username contains a blacklisted string (case insensitive), it's blocked.

        blocked_name_parts.any? { |part| username.downcase.include?(part) }
      end

      private

      def blocked_name_parts
        blocked_names.fetch('manual_blacklist', [])
      end

      def blocked_names
        @blocked_names ||= JSON.parse(blocked_names_page)
      end

      def blocked_names_page
        WikiClient.get_page('Wiki:BotNames.json').body
      end
    end
  end
end
