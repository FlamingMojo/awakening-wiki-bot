# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class ManuallyVerify
    EventUser = Struct.new(:id)
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.admin.manually_verify'

    def content
      return t('not_found') unless target_user && wiki_username
      return t('already_verified', user_id:, wiki_username:) if target_user.verified?(wiki_username)

      target_user.verify(wiki_username)
      t('success', user_id:, wiki_username:)
    rescue StandardError
      'Something went wrong! Ask Mojo'
    end

    private

    def target_user
      DiscordUser.from_discord(EventUser.new(user_id))
    end

    def user_id
      event.options['target_user']
    end

    def wiki_username
      event.options['wiki_username']
    end
  end
end
