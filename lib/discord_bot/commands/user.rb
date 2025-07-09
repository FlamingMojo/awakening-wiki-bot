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
      end

      def register_handlers
        handle_button('verify_board:link', 'DiscordBot::Commands::User::Link')
        handle_modal('verify_board:claim', 'DiscordBot::Commands::User::Claim')
        handle_button('claim:submit_token', 'DiscordBot::Commands::User::SubmitToken')
        handle_modal('claim:verify', 'DiscordBot::Commands::User::Verify')
        handle_button('verify_board:search', 'DiscordBot::Commands::User::Search')
        handle_user_select('search:lookup', 'DiscordBot::Commands::User::Lookup')
        handle_button('editor_tools:discord_source', 'DiscordBot::Commands::User::AddDiscordSource')
        handle_modal('discord_source:add', 'DiscordBot::Commands::User::CreateDiscordSource')
        handle_mention('DiscordBot::Commands::User::UploadImage')
      end
    end
  end
end
