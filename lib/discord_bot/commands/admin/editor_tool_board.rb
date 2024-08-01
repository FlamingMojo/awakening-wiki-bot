# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class EditorToolBoard
    include ::DiscordBot::Util

    def content
      DiscordBot.bot.send_message(*create_params)

      'Posted Tool Board'
    end

    private

    def create_params
      [
        ENV.fetch('DISCORD_TOOL_CHANNEL_ID', ''), # Channel ID
        '', # Message Content
        false, # Text To Speech
        embed, # Embed
        nil, # Attachments
        nil, # Allowed Mentions
        nil, # Message Reference
        buttons, # Components
      ]
    end


    def buttons
      ::Discordrb::Components::View.new do |builder|
        builder.row do |row|
          row.button(label: "Add Discord Source", custom_id: 'editor_tools:discord_source', style: :primary)
        end
      end
    end

    def embed
      Embed.generate
    end

    class Embed
      def self.generate
        new.generate
      end

      def generate
        embed.title = "Editor Tool Board"
        embed.colour = 0xf58a04
        embed.description = "Quick Tools for Wiki Editors to make life easier!"
        embed.thumbnail = thumbnail

        embed
      end

      def thumbnail
        Discordrb::Webhooks::EmbedThumbnail.new(url: ENV['WIKI_THUMBNAIL_URL'])
      end

      def embed
        @embed ||= Discordrb::Webhooks::Embed.new
      end
    end
  end
end
