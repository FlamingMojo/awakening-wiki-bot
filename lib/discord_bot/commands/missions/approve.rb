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
      return t('not_assigned') unless mission.assignee

      mission.approve
      DiscordBot.send_message(
        ENV.fetch('DISCORD_GENERAL_CHANNEL_ID'),
        t('celebration', user: mission.assignee.discord_uid, summary: mission.summary)
      )

      t('approved_mission', summary: mission.summary)
    end

    private

    def mission
      @mission ||= Mission.find_by(id: custom_id.split(':').last)
    end
  end
end
