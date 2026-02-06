# frozen_string_literal: true
require_relative './token'

module DiscordBot::Commands::User
  class Verify
    extend Forwardable
    include Translatable
    include ::DiscordBot::Util

    CODE_REGEX = /WM_(\d{6})_UV/i
    User = Struct.new(:id)

    def_delegators :event, :user, :message
    def_delegators :message, :author, :content

    with_locale_context 'discord_bot.commands.user.verify'

    def handle
      return unless author.id == ENV['DISCORD_UPDATE_FEED_USER_ID'].to_i
      return unless content.match?(CODE_REGEX)
      return unless currently_claiming.any?
      return if already_claimed?
      return unless tokens.values.any?

      complete_verification!
      discord_user.wiki_users.find_or_create_by(username: wiki_username)

      DiscordBot.bot.send_message(ENV.fetch('DISCORD_UPDATE_FEED_CHANNEL_ID', ''), broadcast_message)
    end

    private

    def complete_verification!
      currently_claiming.each { |k| verifications['ongoing']['discord'].delete(k) }
      verifications['verified']['wiki'][wiki_username] = successful_user
      verifications['verified']['discord'][successful_user] ||= []
      verifications['verified']['discord'][successful_user] << wiki_username
      WikiClient.create_page('Discord_verification:all.json', verifications.to_json)
    end

    def broadcast_message
      t('success', wiki_username: wiki_username, user_id: successful_user)
    end

    def successful_user
      tokens.select { |_k,v| v }.keys.first
    end

    def tokens
      @tokens ||= currently_claiming.map { |discord_id| [ discord_id, try_code(discord_id) ] }.to_h
    end

    def try_code(discord_id)
      token = ::DiscordBot::Commands::User::Token.new(user: User.new(discord_id), wiki_user: wiki_username)
      token.verify(code)
    end

    def already_claimed?
      verifications['verified']['wiki'].key?(wiki_username)
    end

    def currently_claiming
      @currently_claiming ||= verifications['ongoing']['discord'].select { |_k, v| v == wiki_username }.keys
    end

    def verifications
      @verifications ||= JSON.parse(WikiClient.get_page('Discord_verification:all.json').body)
    end

    def wiki_username
      @wiki_username ||= URI::Parser.new.unescape(content.match(/User_talk:([^\]]+)>/).captures.first)
    end

    def discord_user
      @discord_user ||= DiscordUser.find_or_create_by(discord_uid: successful_user)
    end

    def code
      content.match(CODE_REGEX).captures.first
    end
  end
end
