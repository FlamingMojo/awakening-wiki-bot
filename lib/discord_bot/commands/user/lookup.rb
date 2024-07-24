# frozen_string_literal: true
require_relative './token'

module DiscordBot::Commands::User
  class Lookup
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.user.lookup'

    def content
      return t('not_found') if wiki_usernames_page.status == 404

      t('found', user_id: user_id, wiki_usernames: wiki_usernames_page.body)
    end

    private

    def wiki_usernames_page
      WikiClient.get_page("Discord_verification:#{user_id}")
    end

    def user_id
      (event.options['user'] || user.id).to_s
    end
  end
end
