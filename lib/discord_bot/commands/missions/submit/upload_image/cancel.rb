# frozen_string_literal: true

# Invoked from button on UploadImage
# Updates previous message to remove buttons.
# Returns message to user.
module DiscordBot::Commands::Missions
  class Submit::UploadImage::Cancel
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.submit.upload_image.cancel'

    def content
      return t('not_found') unless mission
      return t('not_you') unless discord_user == mission.assignee

      mission.update(wiki_page: nil)
      ::Discordrb::API::Channel.delete_message(DiscordBot.bot.token, event.message.channel.id, event.message.id)

      t('cancel_submission', summary: mission.summary)
    end

    private

    def mission
      @mission ||= Mission.in_progress.find_by(id: custom_id.split(':').last)
    end

    def discord_user
      @discord_user ||= DiscordUser.from_discord(user)
    end
  end
end
