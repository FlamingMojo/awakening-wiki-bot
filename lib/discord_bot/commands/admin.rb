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
          cmd.subcommand(:editor_board, t('editor_board'))
          cmd.subcommand(:block_word, 'Add word to username blocklist') do |sub|
            sub.string('word', 'Word to block')
          end
          cmd.subcommand(:unblock_word, 'Remove word from username blocklist') do |sub|
            sub.string('word', 'Word to unblock')
          end
          cmd.subcommand(:manually_verify, 'Manually complete a user verification') do |sub|
            sub.user('target_user', 'Discord user', required: true)
            sub.string('wiki_username', 'Wiki username (Case Sensitive)', required: true)
          end
        end
      end

      def register_handlers
        handle_message('DiscordBot::Commands::Admin::AutoBlock')
        handle(:wiki_admin, :verify_board, 'DiscordBot::Commands::Admin::VerifyBoard')
        handle(:wiki_admin, :block_word, 'DiscordBot::Commands::Admin::AutoBlock::BlacklistWord')
        handle(:wiki_admin, :unblock_word, 'DiscordBot::Commands::Admin::AutoBlock::WhitelistWord')
        handle(:wiki_admin, :manually_verify, 'DiscordBot::Commands::Admin::ManuallyVerify')
        ENV.fetch('DISCORD_ADMIN_IDS', '').split(',').each do |id|
          handle_reaction(
            'DiscordBot::Commands::Admin::ReactionBlock',
            emoji: "❌", from: id.to_i, in: ENV['DISCORD_UPDATE_FEED_CHANNEL_ID'].to_i,
          )
          handle_reaction(
            'DiscordBot::Commands::Admin::ReactionUnblock',
            emoji: '✅', from: id.to_i, in: ENV['DISCORD_UPDATE_FEED_CHANNEL_ID'].to_i,
          )
          handle_reaction(
            'DiscordBot::Commands::Admin::AutoBlock::BlacklistName',
            emoji: '⚠️', from: id.to_i, in: ENV['DISCORD_UPDATE_FEED_CHANNEL_ID'].to_i,
          )
        end
      end
    end
  end
end
