# frozen_string_literal: true

module DiscordBot::Commands::Missions
  class Rewards
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.rewards'

    def content
      return t('no_rewards') unless user_rewards.any?

      t('message', rewards: user_rewards.map(&:to_message).join("\n- "))
    rescue StandardError => e
      "Something went wrong! Ask Mojo! Error: ```#{e.message}```"
    end

    private

    def user_rewards
      @user_rewards ||= discord_user.user_rewards.approved
    end

    def discord_user
      DiscordUser.from_discord(user)
    end
  end
end
