# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class AutoBlock
    class BlacklistName
      extend Forwardable
      include ::DiscordBot::Util

      def_delegators :event, :user, :message
      def_delegators :message, :author, :content

      def handle
        return unless author.id == ENV['DISCORD_UPDATE_FEED_USER_ID'].to_i
        return unless content.end_with?('registered')

        WikiClient.create_page('Wiki:BotNames.json', update_list.to_json)
      end

      private

      def update_list
        blocklist = JSON.parse(blocked_names_page)
        blocklist['names'] = (blocklist['names'] + name_segments).uniq
        blocklist['letters'] = (blocklist['letters'] + letter_segments).uniq
        blocklist['numbers'] = (blocklist['numbers'] + number_segments).uniq

        blocklist
      end

      def letter_segments
        username_parts.reject { |n| n.length > 1 || n =~ /\d+/ }
      end

      def number_segments
        username_parts.select { |n| n =~ /\d+/ }
      end

      def name_segments
        username_parts.reject { |n| n.length <= 1 || n =~ /\d+/ }
      end

      def username_parts
        @username_parts ||= username.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').gsub(/([0-9]+)/,'_\1').gsub('-','_').split('_')
      end

      def blocked_names_page
        WikiClient.get_page('Wiki:BotNames.json').body
      end

      def username
        # Webhook registration messages take the form of:
        # [USERNAME](<User URL>) ([t](<User Talk Page>)|[c](User Contributions page)) registered
        # This regex just captures the username within the first []
        content.match(/\[([^\]]+)\]/).captures.first
      end
    end
  end
end
