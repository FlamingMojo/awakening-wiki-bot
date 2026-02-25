# frozen_string_literal: true

# Invoked from new webhook message in the missions webhook channel
# Tries to parse the message as JSON then create a Mission from it.
module DiscordBot::Commands::Missions
  class WebhookCreate
    extend Forwardable
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.webhook_create'
    def_delegators :event, :message
    def_delegators :message, :content, :channel

    def handle
      return unless channel.id == ENV['DISCORD_MISSIONS_WEBHOOK_CHANNEL_ID'].to_i

      if mission.save
        mission.sync_post!
        DiscordBot.send_message(
          ENV.fetch('DISCORD_MISSIONS_WEBHOOK_CHANNEL_ID'),
          t('success', summary: mission.summary)
        )
      else
        DiscordBot.send_message(
          ENV.fetch('DISCORD_MISSIONS_WEBHOOK_CHANNEL_ID'),
          t('failure', errors: mission.errors.full_messages.join(', '))
        )
      end
    rescue StandardError => error
      DiscordBot.send_message(
        ENV.fetch('DISCORD_MISSIONS_WEBHOOK_CHANNEL_ID'),
        t('error', errors: error.message.truncate(500))
      )
    end

    private

    def mission
      @mission ||= Mission.new(mission_attributes)
    end

    def mission_attributes
      @mission_attributes ||= JSON.parse(content)
    end
  end
end
