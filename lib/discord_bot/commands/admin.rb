# frozen_string_literal: true

module DiscordBot::Commands
  module Admin
    include Subclasses
    include Translatable
    extend ::DiscordBot::CommandHandler

    with_locale_context 'discord_bot.commands.admin.tooltip'

    class << self
      def setup
        register_commands
        register_handlers
      end

      def register_commands
        DiscordBot.slash_command(:wiki_admin, t('wiki_admin')) do |cmd|
          cmd.subcommand(:verify_board, t('verify_board'))
        end
      end

      def register_handlers
        handle(:wiki_admin, :verify_board, 'DiscordBot::Commands::Admin::VerifyBoard')
        handle_reaction(
          'DiscordBot::Commands::Admin::ReactionBlock',
          emoji: "❌", from: ENV['DISCORD_ADMIN_ID'].to_i, in: ENV['DISCORD_UPDATE_FEED_CHANNEL_ID'].to_i,
        )
      end
    end
  end
end
