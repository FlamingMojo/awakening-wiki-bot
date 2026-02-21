# frozen_string_literal: true

# Invoked from button on reward issued in high council channel after 7 missions.
module DiscordBot::Commands::Missions
  class Reward::Confirm
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.reward'

    def content
      return t('not_found') unless user_reward
      return already_claimed if user_already_rewarded?

      user_reward.award(discord_user)
      DiscordBot.send_message(
        ENV.fetch('DISCORD_MISSIONS_NOTIFICATIONS_CHANNEL_ID'),
        t('broadcast', user_id:, reward:)
      )
      DiscordBot.send_message(
        ENV.fetch('DISCORD_HIGH_COUNCIL_CHANNEL_ID'),
        t('approved', user_id:, key:, reward:)
      )
      delete_message

      t('approved', user_id:, key:, reward:)
    end

    def ephemeral
      false
    end

    private

    def delete_message
      ::Discordrb::API::Channel.delete_message(DiscordBot.bot.token, event.message.channel.id, event.message.id)
    end

    def already_claimed
      user_reward.unclaim!
      delete_message
      t('already_claimed')
    end

    def user_already_rewarded?
      rewarded_user.claimed_rewards.include?(user_reward.reward_key)
    end

    def key
      @key ||= user_reward.redacted
    end

    def user_id
      @user_id ||= rewarded_user.discord_uid
    end

    def reward
      @reward ||= user_reward.reward_type.name
    end

    def rewarded_user
      @rewarded_user ||= user_reward.discord_user
    end

    def user_reward
      @user_reward ||= UserReward.find_by(id: custom_id.split(':').last)
    end

    def discord_user
      @discord_user ||= DiscordUser.from_discord(user)
    end
  end
end
