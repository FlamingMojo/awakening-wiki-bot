# frozen_string_literal: true

module DiscordBot::Commands::User
  class Link
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.user.link_modal'

    def response_params
      { title: t('title'), custom_id: 'verify_board:claim' }
    end

    def response_method
      :show_modal
    end

    def response_block
      lambda do |modal|
        modal.row do |row|
          row.text_input(
            style: :short,
            custom_id: 'wiki_username',
            label: t('wiki_username'),
            required: true
          )
        end
      end
    end
  end
end
