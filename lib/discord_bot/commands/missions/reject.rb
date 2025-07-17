# frozen_string_literal: true

# Invoked from Submit embed buttons
# Sets mission back to accepted
# DM's user
# Updates submit embed to remove buttons and update status
module DiscordBot::Commands::Missions
  class Reject
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.reject'

    def content
      return t('not_found') unless mission
      return t('not_submitted') unless mission.submitted?
      return t('not_assigned') unless mission.assignee

      mission.reject
      send_pm(user_id: mission.assignee.discord_uid.to_i, message: t('feedback', summary: mission.summary))

      # Catch the edge case where a user has picked up another mission while awaiting this being accepted.
      mission.update(assignee: nil) if mission.assignee.current_mission

      t('rejected_mission', summary: mission.summary)
    rescue
      t('rejected_mission_no_feedback', summary: mission.summary)
    end

    private

    def mission
      @mission ||= Mission.find_by(id: custom_id.split(':').last)
    end
  end
end
