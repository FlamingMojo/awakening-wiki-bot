# frozen_string_literal: true

module DiscordBot::Commands::User
  class UploadImage
    extend Forwardable
    include ::DiscordBot::Util

    def_delegators :message, :attachments
    def_delegators :event, :message, :text

    def handle
      event.respond(content)
    end

    private

    def content
      return "<@#{user.id}> Sorry, I don't know what you're asking!" unless message_text.start_with?(/upload/i)
      return "<@#{user.id}> You haven't attached any images!" unless attachments.any?
      return "<@#{user.id}> You need to tell me a title for these images!" unless title_base.length

      "<@#{user.id}> Uploaded: #{uploaded_files.join(', ')} for you!"
    rescue
      "<@#{user.id}> Sorry, something went wrong. Ask Mojo for help!"
    end

    def uploaded_files
      attachments.each_with_index.map do |attachment, index|
        filename_base = index.zero? ? title_base : "#{title_base} #{index}"
        discord_image = DiscordImage.new(attachment.url, filename_base)
        discord_image.generate_image_file!
        WikiClient.upload_image(discord_image.filename, discord_image.local_filename, comment, true)
        File.delete(discord_image.local_filename) if File.exist?(discord_image.local_filename)

        discord_image.filename
      end
    end

    def comment
      "Uploaded via Discord by #{user.global_name}"
    end

    def title_base
      message_text.sub(/upload/i, '').strip
    end

    def message_text
      text.gsub("<@#{DiscordBot.bot.instance_variable_get('@client_id')}>", '').strip
    end

    class DiscordImage
      attr_reader :url, :filename_base
      private :url, :filename_base

      def initialize(url, filename_base)
        @url = url
        @filename_base = filename_base
      end

      def generate_image_file!
        File.open(local_filename, 'wb') { |fp| fp.write(image_response.body) }
      end

      def local_filename
        @local_filename ||= "./#{filename}"
      end

      def filename
        @filename ||= "#{filename_base}.#{file_extension}"
      end

      private

      def image_response
        @image_response ||= Faraday.get(url)
      end

      def file_extension
        # URL is always https://cdn.discordapp.com/attachments/server_id/channel_id/filename.ext?cache=params
        url.split('/').last.split('?').first.split('.').last
      end
    end
  end
end
