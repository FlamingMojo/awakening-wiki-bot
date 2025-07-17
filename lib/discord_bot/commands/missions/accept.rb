# frozen_string_literal: true

# Invoked from mission post button from Create
# Updates embed/buttons on mission post
# Returns message to user
module DiscordBot::Commands::Missions
  class Accept
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.accept'

    def content
      return t('not_found') unless mission
      return t('must_verify') unless wiki_users.any?
      return t('already_on_mission', summary: discord_user.current_mission.summary) if discord_user.current_mission

      mission.accept(discord_user)

      t('accepted_mission', summary: mission.summary, instructions: mission.instructions)
    end

    def mission
      @mission ||= Mission.find_by(id: custom_id.split(':').last)
    end

    def discord_user
      @discord_user ||= DiscordUser.from_discord(user)
    end

    def wiki_users
      @wiki_users ||= WikiUser.lookup(user.id)
    end
  end
end
