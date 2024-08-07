# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class ReactionUnblock
    extend Forwardable
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.admin.reaction_unblock'
    def_delegators :event, :user, :message
    def_delegators :message, :author, :content

    def handle
      return unless author.id == ENV['DISCORD_UPDATE_FEED_USER_ID'].to_i
      return unless content.end_with?('registered')

      WikiClient.raw_action(:unblock, user: target_username, reason: t('reason', admin: user.global_name))
    end

    def target_username
      # Webhook registration messages take the form of:
      # [USERNAME](<User URL>) ([t](<User Talk Page>)|[c](User Contributions page)) registered
      # This regex just captures the username within the first []
      content.match(/\[([^\]]+)\]/).captures.first
    end
  end
end


