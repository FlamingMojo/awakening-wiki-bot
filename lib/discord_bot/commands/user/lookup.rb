# frozen_string_literal: true
require_relative './token'

module DiscordBot::Commands::User
  class Lookup
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.user.lookup'

    def content
      return t('not_found') unless wiki_users.any?

      t('found', user_id: user_id, wiki_usernames: wiki_users.map(&:username).join(', '))
    end

    def response_method
      :update_message
    end

    private

    def wiki_users
      @wiki_users ||= WikiUser.lookup(user_id)
    end

    def user_id
      event.values.first.id || user.id
    end
  end
end
