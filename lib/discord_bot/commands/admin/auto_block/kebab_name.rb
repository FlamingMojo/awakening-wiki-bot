# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class AutoBlock
    # Used to block CommonNames (more often business names) that use kebab-case
    class KebabName < CommonName

      private

      def name_segments
        username_parts.delete_if { |n| n.length <= 1 }
      end

      def username_parts
        @username_parts ||= username.split('-').map { |n| n.gsub(/\d+/, '') }
      end
    end
  end
end
