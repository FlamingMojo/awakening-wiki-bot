# frozen_string_literal: true

# Invoked from Submit embed buttons
# Completes the mission
# DM's user
# Deletes mission post
# Updates submit embed to remove buttons and update status
module DiscordBot::Commands::Missions
  class Approve
    # To refactor into the rewards model
    MILESTONES = [7]
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
      if MILESTONES.include?(mission_count)
        DiscordBot.send_message(
          ENV.fetch('DISCORD_MISSIONS_NOTIFICATIONS_CHANNEL_ID'),
          t('reward', user: assignee.discord_uid, count: mission_count)
        )
      end

      t('approved_mission', summary: mission.summary)
    end

    private

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
