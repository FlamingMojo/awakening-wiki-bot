# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class AutoBlock
    extend Forwardable
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.admin.auto_block'
    def_delegators :event, :user, :message
    def_delegators :message, :author, :content

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
      # Every spam account has been created with a username matching the following criteria
      #  - 4-9 characters, a-z, no spaces
      #  - First character is a vowel, then alternating consonant, vowel, consonant (counting y as a vowel)
      # So this auto-detects and blocks those usernames. They can be unblocked manually by admin afterwards if in error.
      return false unless target_username.match?(/\A[a-z]{4,9}\z/i)
      even, odd = *(target_username.chars.partition.each_with_index { |_v, i| i.even? })

      even.join('').match?(/^[aeiouy]+$/i) && odd.join('').match?(/^[^aeiouy]+$/i)
    end

    def target_username
      # Webhook registration messages take the form of:
      # [USERNAME](<User URL>) ([t](<User Talk Page>)|[c](User Contributions page)) registered
      # This regex just captures the username within the first []
      @target_username ||= content.match(/\[([^\]]+)\]/).captures.first
    end
  end
end


