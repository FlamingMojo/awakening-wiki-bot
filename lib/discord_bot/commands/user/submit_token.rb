# frozen_string_literal: true

module DiscordBot::Commands::User
  class SubmitToken
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.user.submit_token'

    def response_params
      { title: t('title'), custom_id: 'claim:verify' }
    end

    def response_method
      :show_modal
    end

    def response_block
      lambda do |modal|
        modal.row do |row|
          row.text_input(
            style: :short,
            custom_id: 'code',
            label: t('prompt'),
            required: true
          )
        end
      end
    end
  end
end
