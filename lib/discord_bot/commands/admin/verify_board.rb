# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class VerifyBoard
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.admin.verify_board'

    def content
      DiscordBot.bot.send_message(*create_params)

      t('success')
    end

    private

    def create_params
      [
        ENV.fetch('DISCORD_VERIFY_CHANNEL_ID', ''), # Channel ID
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
          row.button(label: t('link'), custom_id: 'verify_board:link', style: :primary)
          row.button(label: t('lookup'), custom_id: 'verify_board:search', style: :secondary)
        end
      end
    end

    def embed
      Embed.generate
    end

    class Embed
      include Translatable
      with_locale_context 'discord_bot.commands.admin.verify_board.embed'

      def self.generate
        new.generate
      end

      def generate
        embed.title = t('title')
        embed.colour = 0xf58a04
        embed.description = t("description")
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
