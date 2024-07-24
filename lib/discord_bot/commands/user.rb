# frozen_string_literal: true

module DiscordBot::Commands
  module User
    include Subclasses
    include Translatable
    extend ::DiscordBot::CommandHandler

    with_locale_context 'discord_bot.commands.user.tooltip'

    class << self
      def setup
        register_commands
        register_handlers
      end

      def register_commands
        DiscordBot.slash_command(:wiki_user, t('wiki_user')) do |cmd|
          cmd.subcommand(:claim, t('claim')) do |sub|
            sub.string('wiki_username', t('wiki_username'), required: true)
          end
          cmd.subcommand(:verify, t('verify')) do |sub|
            sub.string('code', t('code'), required: true)
          end
          cmd.subcommand(:lookup, t('lookup')) do |sub|
            sub.user('user', t('user'))
          end
        end
      end

      def register_handlers
        handle(:wiki_user, :claim, 'DiscordBot::Commands::User::Claim')
        handle(:wiki_user, :verify, 'DiscordBot::Commands::User::Verify')
        handle(:wiki_user, :lookup, 'DiscordBot::Commands::User::Lookup')
      end
    end
  end
end
