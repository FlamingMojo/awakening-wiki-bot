# frozen_string_literal: true

class Mission
  class Post
    include Translatable

    with_locale_context 'mission.post'

    attr_reader :mission
    private :mission

    def initialize(mission)
      @mission = mission
    end

    def create
      DiscordBot.send_message(*create_params)
    end

    def update
      return move if mission.channel_uid != channel

      ::Discordrb::API::Channel.edit_message(*update_params)
    end

    def move
      delete
      post_message = create
      mission.update(
        discord_post_uid: post_message.id,
        discord_post_link: t('link', message_id: post_message.id, channel_id: channel)
      )
    end

    def delete
      ::Discordrb::API::Channel.delete_message(*delete_params)
    end

    def create_params
      [
        channel, # Channel ID
        content, # Message Content
        false, # Text To Speech
        mission.embed, # Embed
        nil, # Attachments
        nil, # Allowed Mentions
        nil, # Message Reference
        buttons, # Components
      ]
    end

    def update_params
      [
        DiscordBot.bot.token,
        mission.channel_uid, # Channel ID
        mission.discord_post_uid, # Message ID
        content, # New Message Content
        [], # Mentions
        [mission.embed], # Embed
        buttons.to_a, #Components
      ]
    end

    def delete_params
      [DiscordBot.bot.token, mission.channel_uid, mission.discord_post_uid]
    end

    def channel
      return ENV.fetch('DISCORD_MISSIONS_BOARD_CHANNEL_ID', '') if mission.active?
      return ENV.fetch('DISCORD_MISSIONS_IN_PROGRESS_CHANNEL_ID', '') if mission.accepted?
      return ENV.fetch('DISCORD_MISSIONS_SUBMISSIONS_CHANNEL_ID', '') if mission.submitted?
      return ENV.fetch('DISCORD_MISSIONS_COMPLETED_CHANNEL_ID', '') if mission.completed?

      ENV.fetch('DISCORD_MISSIONS_BOARD_CHANNEL_ID', '')
    end

    def content
      return '' unless context == :admin

      t('admin_notification')
    end

    def buttons
      return [] if context == :archive

      ::Discordrb::Components::View.new do |builder|
        builder.row do |row|
          active_buttons.each do |button|
            row.button(**button)
          end
        end
      end
    end

    def active_buttons
      return [accept_button] if context == :live

      [approve_button, reject_button]
    end

    def accept_button
      {
        label: t('accept_mission'),
        custom_id: "mission:accept:#{mission.id}",
        style: :success,
        disabled: !mission.active?
      }
    end

    def approve_button
      {
        label: t('approve_mission'),
        custom_id: "mission:approve:#{mission.id}",
        style: :success,
        disabled: !mission.submitted?
      }
    end

    def reject_button
      {
        label: t('reject_mission'),
        custom_id: "mission:reject:#{mission.id}",
        style: :danger,
        disabled: !mission.submitted?
      }
    end

    def context
      @context ||= mission.context
    end
  end
end
