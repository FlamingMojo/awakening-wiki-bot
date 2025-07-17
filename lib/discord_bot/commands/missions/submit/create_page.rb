# frozen_string_literal: true

# Invoked from new created webhook message
# Checks for any active page create missions
# Compares page url
# Compares wiki username
# Invoked Mission Submit with details
module DiscordBot::Commands::Missions
  class Submit::CreatePage
    extend Forwardable
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.submit.create_page'
    def_delegators :event, :user, :message
    def_delegators :message, :author, :content

    def handle
      return unless author.id == ENV['DISCORD_UPDATE_FEED_USER_ID'].to_i
      return unless created_page? || edited_page?
      return unless Mission.accepted.page_create.any?
      return unless wiki_user
      return unless mission.assignee == discord_user

      mission.submit
      DiscordBot.send_message(
        ENV.fetch('DISCORD_UPDATE_FEED_CHANNEL_ID'),
        t('notify', summary: mission.summary, user: discord_user.discord_uid)
      )
    end

    def created_page?
      content.include?(')) created [')
    end

    def edited_page?
      content.include?(')) edited [')
    end

    def mission
      @mission ||= Mission.accepted.page_create.find_by(wiki_page: target_page)
    end

    def target_page
      return content.split(')) created [').last.match(/<([^>]*)>/).captures.first if created_page?

      content.split(')) edited [').last.match(/<([^>]*)>/).captures.first
    end

    def discord_user
      @discord_user ||= wiki_user.discord_user
    end

    def wiki_user
      @wiki_user ||= WikiUser.find_by(username: target_username)
    end

    def target_username
      @target_username ||= URI::Parser.new.unescape(content.match(/User_talk:([^\]]+)>/).captures.first)
    end
  end
end
