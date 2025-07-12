# frozen_string_literal: true

# Invoked from admin slash command /post_mission
# Returns dropdown of mission types
module DiscordBot::Commands::Missions
  class Init
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.init'

    def content
      t('prompt')
    end

    def response_block
      lambda do |_builder, view|
        view.row do |r|
          r.select_menu(custom_id: 'mission:new', placeholder: t('placeholder'), max_values: 1) do |s|
            Mission::TYPES.each do |type|
              s.option(label: t(type), value: type)
            end
          end
        end
      end
    end
  end
end
