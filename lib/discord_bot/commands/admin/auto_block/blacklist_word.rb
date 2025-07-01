# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class AutoBlock::BlacklistWord
    include ::DiscordBot::Util

    def content
      return 'You do not have permission to do this.' unless admin?
      return 'Need to include word' unless word
      WikiClient.create_page('Wiki:BotNames.json', update_list.to_json)
      DiscordBot.bot.send_message(ENV.fetch('DISCORD_UPDATE_FEED_CHANNEL_ID', ''), broadcast_message)

      return_message
    rescue
      'Something went wrong.'
    end

    private

    def broadcast_message
      "#{user.global_name} added #{word} to the blocklist."
    end

    def return_message
      "Added #{word} to the blacklist."
    end

    def word
      event.options['word']
    end

    def update_list
      blocklist = JSON.parse(blocked_names_page)
      blocklist['manual_blacklist'] = (blocklist['manual_blacklist'] + [word.downcase]).uniq

      blocklist
    end

    def blocked_names_page
      WikiClient.get_page('Wiki:BotNames.json').body
    end

    def admin?
      ENV.fetch('DISCORD_ADMIN_IDS', '').split(',').map(&:to_i).include?(user.id)
    end
  end
end
