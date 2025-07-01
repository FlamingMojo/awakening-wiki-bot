# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class AutoBlock::WhitelistWord < AutoBlock::BlacklistWord
    include ::DiscordBot::Util

    private

    def broadcast_message
      "#{user.global_name} removed #{word} from the blocklist."
    end

    def return_message
      "Removed #{word} from the blacklist."
    end

    def update_list
      blocklist = JSON.parse(blocked_names_page)
      blocklist['manual_blacklist'] = (blocklist['manual_blacklist'] - [word.downcase]).uniq

      blocklist
    end
  end
end
