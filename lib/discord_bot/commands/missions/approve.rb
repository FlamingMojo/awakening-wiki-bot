# frozen_string_literal: true

# Invoked from Submit embed buttons
# Completes the mission
# DM's user
# Deletes mission post
# Updates submit embed to remove buttons and update status
module DiscordBot::Commands::Missions
  class Approve
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.approve'

    def content
      return t('not_found') unless mission
      return t('not_submitted') unless mission.submitted?
      return t('not_assigned') unless assignee

      mission.approve
      DiscordBot.send_message(
        ENV.fetch('DISCORD_MISSIONS_NOTIFICATIONS_CHANNEL_ID'),
        t('celebration', user: assignee.discord_uid, summary: mission.summary, count: mission_count)
      )
      handle_reward

      t('approved_mission', summary: mission.summary)
    end

    private

    def handle_reward
      return unless reward_types.map(&:threshold).include?(mission_count)
      return out_of_stock unless reward_type_due.in_stock?

      user_reward
      DiscordBot.send_message(
        ENV.fetch('DISCORD_HIGH_COUNCIL_CHANNEL_ID'),
        t('reward', user: assignee.discord_uid, count: mission_count, reward: reward_type_due.name),
        false, nil, nil, nil, nil, confirm_button
      )
    end

    def reward_types
      @reward_types ||= RewardType.mission_count
    end

    def reward_type_due
      @reward_type_due ||= reward_types.find_by(threshold: mission_count)
    end

    def out_of_stock
      DiscordBot.send_message(
        ENV.fetch('DISCORD_HIGH_COUNCIL_CHANNEL_ID'),
        t('reward_out_of_stock', user: assignee.discord_uid, reward: reward_type_due.name)
      )
    end

    def user_reward
      @user_reward ||= reward_type_due.next_reward.issue_to(assignee)
    end

    def confirm_button
      ::Discordrb::Components::View.new do |builder|
        builder.row do |row|
          row.button(label: t('confirm'), custom_id: "mission:reward:confirm:#{user_reward.id}", style: :success)
        end
      end
    end

    def mission_count
      @mission_count ||= assignee.reload.missions.completed.count
    end

    def assignee
      @assignee ||= mission.assignee
    end

    def mission
      @mission ||= Mission.find_by(id: custom_id.split(':').last)
    end
  end
end
