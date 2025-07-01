# frozen_string_literal: true

module DiscordBot::Commands::Admin
  class ReactionBlock
    extend Forwardable
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.admin.reaction_block'
    def_delegators :event, :user, :message
    def_delegators :message, :author, :content

    def handle
      return unless author.id == ENV['DISCORD_UPDATE_FEED_USER_ID'].to_i
      return unless registered_user? || created_page?

      if registered_user?
        block_user!
      else
        delete_page!
      end
    end

    def block_user!
      WikiClient.raw_action(
        :block,
        user: target_username,
        reason: t('reason', admin: user.global_name),
        autoblock: true,
        nocreate: true,
        noemail: true,
      )
    end

    def target_username
      # Webhook registration messages take the form of:
      # [USERNAME](<User URL>) ([t](<User Talk Page>)|[c](User Contributions page)) registered
      # This regex just captures the username within the first []
      URI::Parser.new.unescape(content.match(/User_talk:([^\]]+)>/).captures.first)
    end

    def delete_page!
      WikiClient.delete_page(target_page, t('reason', admin: user.global_name))
    end

    def target_page
      # Webhook created messages take the form of:
      # [USERNAME](<User URL>) ([t](<User Talk Page>)|[c](User Contributions page)) created [Page Title](link) ...
      # This regex just captures the page name within the first [] after 'created'
      content.split('created').last.match(/\[([^\]]+)\]/).captures
    end

    def registered_user?
      content.end_with?('registered')
    end

    def created_page?
      content.include?(')) created [')
    end
  end
end
