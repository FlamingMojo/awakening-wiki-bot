# frozen_string_literal: true

# Invoked from admin command
# Finds mission by ID. If submitted/completed, warn
# Completes the mission
# If any assignee, DM's them and removes them
# Deletes mission post
module DiscordBot::Commands::Missions
  class Cancel
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.cancel'

    def content
      return t('not_found') unless mission

      mission.cancel

      t('cancelled_mission', summary: mission.summary)
    end

    private

    def mission
      @mission ||= Mission.in_progress.find_by(id: event.options['id'])
    end
  end
end
