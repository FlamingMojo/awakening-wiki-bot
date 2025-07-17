# frozen_string_literal: true

# Invoked from upload image where user has active mission (non-command)
# Returns array of buttons for response
module DiscordBot::Commands::Missions
  class Submit::UploadImage
    include Subclasses
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.submit.upload_image'

    attr_reader :discord_user, :uploaded_files, :channel
    private :discord_user, :uploaded_files, :channel

    def initialize(discord_user:, uploaded_files:, channel:)
      @discord_user = discord_user
      @uploaded_files = uploaded_files
      @channel = channel
    end

    def handle
      return unless (mission && uploaded_files.any?)
      # Store a file URL first. If cancelled it can be removed later
      mission.update(wiki_page: t('link', image_name: uploaded_files.first.gsub(' ', '_')))

      DiscordBot.send_message(channel, t('prompt', summary: mission.summary), false, nil, nil, nil, nil, buttons)
    end

    private

    def mission
      @mission ||= discord_user.current_mission
    end

    def buttons
      ::Discordrb::Components::View.new do |builder|
        builder.row do |row|
          row.button(label: t('confirm_button'), custom_id: "mission:image:confirm:#{mission.id}", style: :success)
          row.button(label: t('cancel_button'), custom_id: "mission:image:cancel:#{mission.id}", style: :danger)
        end
      end
    end
  end
end
