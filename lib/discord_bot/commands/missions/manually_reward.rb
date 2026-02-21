# frozen_string_literal: true

module DiscordBot::Commands::Missions
  class ManuallyReward
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.manually_reward'

    def content
      return t('not_found') unless assignee
      return out_of_stock unless reward_type_due.in_stock?

      user_reward
      DiscordBot.send_message(
        ENV.fetch('DISCORD_HIGH_COUNCIL_CHANNEL_ID'),
        t('reward', user: assignee.discord_uid, reward: reward_type_due.name, admin: user.id),
        false, nil, nil, nil, nil, confirm_button
      )

      t('issued')
    end

    private

    def reward_type_due
      # Temporary - Hardcode to the first mission (Atreides Battle Rifle)
      @reward_type_due ||= RewardType.first
    end

    def assignee
      DiscordUser.find_or_create_by(discord_uid: user_id)
    end

    def user_id
      event.options['target_user'].to_s
    end

    def out_of_stock
      DiscordBot.send_message(
        ENV.fetch('DISCORD_HIGH_COUNCIL_CHANNEL_ID'),
        t('reward_out_of_stock', user: assignee.discord_uid, reward: reward_type_due.name)
      )
    end

    def user_reward
      @user_reward ||= reward_type_due.next_reward.issue_to(assignee, issue_type: :manual)
    end

    def confirm_button
      ::Discordrb::Components::View.new do |builder|
        builder.row do |row|
          row.button(label: t('confirm'), custom_id: "mission:reward:confirm:#{user_reward.id}", style: :success)
        end
      end
    end
  end
end
