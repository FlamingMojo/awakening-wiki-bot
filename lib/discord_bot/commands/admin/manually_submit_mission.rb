# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class ManuallySubmitMission
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.admin.manually_submit_mission'

    def content
      return t('not_found') unless mission
      return t('not_accepted') unless mission.accepted?

      mission.submit

      DiscordBot.send_message(
        ENV.fetch('DISCORD_UPDATE_FEED_CHANNEL_ID'),
        t('notify', summary: mission.summary, user: mission.assignee.discord_uid)
      )

      t('success', mission_id:)
    rescue StandardError => e
      "Something went wrong! Ask Mojo! Error: ```#{e.message}```"
    end

    private

    def mission
      @mission ||= Mission.find_by(id: mission_id)
    end

    def mission_id
      event.options['mission_id']
    end
  end
end
