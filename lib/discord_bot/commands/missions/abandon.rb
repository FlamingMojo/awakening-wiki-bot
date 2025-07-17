# frozen_string_literal: true

# Invoked from user command
# Check user has any assigned missions, if not, warn.
# Remove user from assigned mission
# Update mission to active, update embed and buttons.
module DiscordBot::Commands::Missions
  class Abandon
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.abandon'

    def content
      return t('not_found') unless mission

      mission.abandon

      t('abandoned_mission', summary: mission.summary)
    end

    private

    def mission
      @mission ||= discord_user.current_mission
    end

    def discord_user
      @discord_user ||= DiscordUser.from_discord(user)
    end
  end
end
