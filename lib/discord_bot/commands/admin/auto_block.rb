# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class AutoBlock
    include Subclasses
    extend Forwardable
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.admin.auto_block'
    def_delegators :event, :user, :message
    def_delegators :message, :author, :content

    MATCHERS = [EvenOdd, CommonName]

    def handle
      return unless author.id == ENV['DISCORD_UPDATE_FEED_USER_ID'].to_i
      return unless content.end_with?('registered')
      return unless spam_account?

      WikiClient.raw_action(
        :block,
        user: target_username,
        reason: t('reason'),
        autoblock: true,
        nocreate: true,
        noemail: true,
      )
    end

    def spam_account?
      MATCHERS.any? { |matcher| matcher.new(target_username).match? }
    end

    def target_username
      # Webhook registration messages take the form of:
      # [USERNAME](<User URL>) ([t](<User Talk Page>)|[c](User Contributions page)) registered
      # This regex just captures the username within the first []
      @target_username ||= URI::Parser.new.unescape(content.match(/User_talk:([^\]]+)>/).captures.first)
    end
  end
end
