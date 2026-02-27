# frozen_string_literal: true

module DiscordBot::Commands::User
  class UploadImage
    extend Forwardable
    include ::DiscordBot::Util
    include Translatable

    with_locale_context 'discord_bot.commands.user.upload_image'

    def_delegators :message, :attachments
    def_delegators :event, :message, :text

    def handle
      event.respond(content)
    end

    private

    def content
      return t('unknown_command', user_id: user.id) unless message_text.start_with?(/upload/i)
      return t('no_attachments', user_id: user.id) unless attachments.any?
      return t('no_title', user_id: user.id) unless title_base.length
      return t('rules_not_met', user_id: user.id, errors: rule_errors.flatten.join("\n- ")) unless rules_met?

      upload_files_to_wiki
      t('success', user_id: user.id, files: uploaded_files.map(&:filename).join("\n- "))
    rescue => e
      return t('aborted_error') if e.message == 'Aborted'
      t('error', user_id: user.id, error: e.message.truncate(500))
    end

    def uploaded_files
      @uploaded_files ||= attachments.each_with_index.map do |attachment, index|
        filename_base = index.zero? ? title_base : "#{title_base} #{index}"
        discord_image = DiscordImage.new(attachment.url, filename_base)
        discord_image.generate_image_file!

        discord_image
      end
    end

    def upload_files_to_wiki
      uploaded_files.each do |file|
        WikiClient.upload_image(file.filename, file.local_filename, comment, true)
        File.delete(file.local_filename) if File.exist?(file.local_filename)
      end
    end

    def comment
      t('comment', username: user.global_name || user.username)
    end

    def title_base
      message_text.sub(/upload/i, '').strip
    end

    def message_text
      text.gsub("<@#{DiscordBot.bot.instance_variable_get('@client_id')}>", '').strip
    end

    def discord_user
      @discord_user ||= DiscordUser.from_discord(user)
    end

    def rules_met?
      return true unless current_mission&.image_upload?
      return handle_mission unless current_mission.image_rule

      uploaded_files.all? do |file|
        matcher = current_mission.image_rule.matcher(file)
        matcher.match?.tap { rule_errors << matcher.errors }
      end.tap { |all| handle_mission if all }
    end

    def rule_errors
      @rule_errors ||= []
    end

    def handle_mission
      ::DiscordBot::Commands::Missions::Submit::UploadImage.new(
        discord_user: discord_user, uploaded_files: uploaded_files, channel: event.channel
      ).handle
    end

    def current_mission
      @current_mission ||= discord_user.current_mission
    end

    class DiscordImage
      attr_reader :url, :filename_base, :width, :height, :format
      private :url, :filename_base

      def initialize(url, filename_base)
        @url = url
        @filename_base = filename_base
      end

      def generate_image_file!
        File.open(local_filename, 'wb') { |fp| fp.write(image_response.body) }
        @width, @height = *(FastImage.size(local_filename) || [0,0])
        @format = FastImage.type(local_filename) || :unknown
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
