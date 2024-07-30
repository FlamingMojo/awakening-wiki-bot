# frozen_string_literal: true

module DiscordBot::Commands::User
  class Search
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.user.search'

    def content
      t('content')
    end

    def response_block
      lambda do |_builder, view|
        view.row do |row|
          row.user_select(custom_id: 'search:lookup', max_values: 1, min_values: 1, placeholder: t('placeholder'))
        end
      end
    end
  end
end
