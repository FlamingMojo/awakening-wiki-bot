# frozen_string_literal: true

# Invoked from mission modal from New
# Posts mission embed with buttons.
# Returns confirmation to admin
module DiscordBot::Commands::Missions
  class Create
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.create'

    def content
      return t('errors', errors: mission.errors.full_messages) unless mission.persisted?
      mission.sync_post!

      t('success', id: mission.id, link: mission.discord_post_link)
    end

    def response_method
      :update_message
    end

    private

    def mission
      @mission ||= Mission.create(
        type: type,
        issuer: issuer,
        **modal_values.symbolize_keys.delete_if { |_, v| v.empty? }
      )
    end

    def issuer
      @issuer ||= DiscordUser.from_discord(member)
    end

    def type
      custom_id.split(':').last
    end

    def modal_keys
      %w[title description wiki_page map_link]
    end
  end
end
