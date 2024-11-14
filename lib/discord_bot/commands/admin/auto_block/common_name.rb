# frozen_string_literal: true

# require './base_matcher'

module DiscordBot::Commands::Admin
  class AutoBlock
    class CommonName
      # include BaseMatcher

      attr_reader :username
      private :username

      def initialize(username)
        @username = username
      end

      def match?
        # These bots combine 3 name parts:
        # - One or more common-sounding name segments e.g. Ashlee, Orval, Tyson
        # - Zero or more groups of either:
        #  - Random Numbers
        #  - Random single capital characters
        # For this matcher, we only want to check that the name segments only consist of the known blocklist of names
        return unless name_segments.any?

        name_segments.all? { |name| blocked_name_parts.include?(name) }
      end

      private

      def name_segments
        username_parts.delete_if { |n| n.length <= 1 || n =~ /\d+/ }
      end

      def username_parts
        @username_parts ||= username.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').gsub(/([0-9]+)/,'_\1').split('_')
      end

      def blocked_name_parts
        blocked_names.fetch('names', [])
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
