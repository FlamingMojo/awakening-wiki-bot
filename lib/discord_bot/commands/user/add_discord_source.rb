# frozen_string_literal: true

module DiscordBot::Commands::User
  class AddDiscordSource
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.user.add_discord_source'

    def response_params
      { title: t('title'), custom_id: 'discord_source:add' }
    end

    def response_method
      :show_modal
    end

    def response_block
      lambda do |modal|
        %w[date author link image_url].each do |field|
          modal.row do |row|
            row.text_input(
              style: :short,
              custom_id: field,
              label: t(field),
              required: true
            )
          end
        end
        modal.row do |row|
          row.text_input(
            style: :paragraph,
            custom_id: 'text',
            label: t('text'),
            required: true
          )
        end
      end
    end
  end
end
