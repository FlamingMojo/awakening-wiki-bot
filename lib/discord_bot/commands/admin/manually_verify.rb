# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class ManuallyVerify
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.admin.manually_verify'

    def content
      return t('not_found') unless target_user && wiki_username
      return t('already_verified', user_id:, wiki_username:) if target_user.verified?(wiki_username)

      target_user.verify!(wiki_username)
      t('success', user_id:, wiki_username:)
    rescue StandardError => e
      "Something went wrong! Ask Mojo! Error: ```#{e.message}```"
    end

    private

    def target_user
      DiscordUser.find_or_create_by(discord_uid: user_id)
    end

    def user_id
      event.options['target_user'].to_s
    end

    def wiki_username
      event.options['wiki_username']
    end
  end
end
