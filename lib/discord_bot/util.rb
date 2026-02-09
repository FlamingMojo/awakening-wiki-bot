# frozen_string_literal: true

module DiscordBot
  module Util
    attr_reader :event

    # While this defines #initialize, it is still a module and cannot be instantiated.
    def initialize(event)
      @event = event
      DiscordUser.find_or_create_by(discord_uid: user.id).update(username: user.username) if user
    end

    def response_block
      -> (builder, view) {}
    end

    def response_params
      {
        allowed_mentions: allowed_mentions,
        components: components,
        content: content,
        embeds: embeds,
        ephemeral: ephemeral,
        flags: flags,
        tts: tts,
        wait: wait_for_response,
      }.compact
    end

    def response_method
      :respond
    end

    def after_response
      -> (message) {}
    end

    def allowed_mentions; end
    def content; end
    def components; end
    def embed; end
    def flags; end # flags should be an int, but as response_params is compacted it assumes the method default of 0
    def tts
      false
    end
    def wait_for_response; end # If using an after_response, ensure that this is true

    def embeds
      return [] unless embed

      [embed]
    end

    def ephemeral
      true # By default make all bot responses only visible to the invoking user
    end

    private

    def custom_id
      event.interaction.data['custom_id']
    end

    def modal_keys
      %w[]
    end

    def modal_values
      @modal_values ||= modal_keys.each_with_object({}) do |attribute, hash|
        hash[attribute] = event.value(attribute)
      end
    end

    # Helper method to get (a) user on the server, defaulting to the user initiating the event
    def member(user_id = nil)
      return event.user.on(ENV['DISCORD_SERVER_ID']) unless user_id

      DiscordBot.server.member(user_id.to_i)
    end

    # Helper method to PM a user
    def send_pm(user_id:, message:, tts: nil, embed: nil, attachments: nil, mentions: nil, ref: nil, actions: nil)
      DiscordBot.send_message(
        DiscordBot.pm_channel(user_id), message, tts, embed, attachments, mentions, ref, actions
      )
    end

    def user
      @user ||= event.user
    end
  end
end
