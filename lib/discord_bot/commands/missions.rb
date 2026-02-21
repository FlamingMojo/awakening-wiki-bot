# frozen_string_literal: true

module DiscordBot::Commands
  module Missions
    include Subclasses
    include Translatable
    extend ::DiscordBot::CommandHandler

    with_locale_context 'discord_bot.commands.missions.tooltip'

    class << self
      def setup
        register_commands
        register_handlers
      end

      def register_commands
        DiscordBot.slash_command(:post_mission, t('post'))
        DiscordBot.slash_command(:abandon_mission, t('abandon'))
        DiscordBot.slash_command(:cancel_mission, t('cancel')) do |cmd|
          cmd.string('id', t('fields.id'), required: true)
        end
        DiscordBot.slash_command(:missions, t('count')) do |cmd|
          cmd.user('target_user', 'Other discord user', required: false)
        end
        DiscordBot.slash_command(:manual_reward, t('manually_reward')) do |cmd|
          cmd.user('target_user', 'Discord user', required: true)
        end
        DiscordBot.slash_command(:rewards, t('rewards'))
      end

      def register_handlers
        handle_message('DiscordBot::Commands::Missions::Submit::CreatePage')
        handle_message('DiscordBot::Commands::Missions::Submit::UpdatePage')
        handle_command(:post_mission, 'DiscordBot::Commands::Missions::Init')
        handle_select_menu('mission:new', 'DiscordBot::Commands::Missions::New')
        handle_modal(/^mission:create:/, 'DiscordBot::Commands::Missions::Create')
        handle_button(/^mission:accept:/, 'DiscordBot::Commands::Missions::Accept')
        handle_button(/^mission:approve:/, 'DiscordBot::Commands::Missions::Approve')
        handle_button(/^mission:reject:/, 'DiscordBot::Commands::Missions::Reject')
        handle_button(/^mission:image:confirm:/, 'DiscordBot::Commands::Missions::Submit::UploadImage::Confirm')
        handle_button(/^mission:image:cancel:/, 'DiscordBot::Commands::Missions::Submit::UploadImage::Cancel')
        handle_button(/^mission:reward:confirm:/, 'DiscordBot::Commands::Missions::Reward::Confirm')

        handle_command(:abandon_mission, 'DiscordBot::Commands::Missions::Abandon')
        handle_command(:cancel_mission, 'DiscordBot::Commands::Missions::Cancel')
        handle_command(:missions, 'DiscordBot::Commands::Missions::Count')
        handle_command(:rewards, 'DiscordBot::Commands::Missions::Rewards')
        handle_command(:manual_reward, 'DiscordBot::Commands::Missions::ManuallyReward')
      end
    end
  end
end


