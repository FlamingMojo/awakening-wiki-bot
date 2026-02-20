# frozen_string_literal: true

module DiscordBot::Commands::Missions
  class Count
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.count'

    def content
      return t('not_found') unless target_user

      if other_user?
        t('found', user_id: target_user.discord_uid, count: missions_count)
      else
        t('found_self', count: missions_count)
      end
    rescue StandardError => e
      "Something went wrong! Ask Mojo! Error: ```#{e.message}```"
    end

    private

    def missions_count
      @missions_count ||= target_user.missions.completed.count
    end

    def target_user
      @target_user ||= find_user
    end

    def find_user
      return DiscordUser.from_discord(user) unless other_user?

      DiscordUser.find_or_create_by(discord_uid: user_id)
    end

    def other_user?
      !!event.options['target_user']
    end

    def user_id
      event.options['target_user'].to_s
    end
  end
end
