# frozen_string_literal: true
require_relative './token'

module DiscordBot::Commands::User
  class Verify
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.user.verify'

    def content
      return t('no_claim') unless currently_claiming?
      return already_claimed_message if already_claimed?
      return t('incorrect_code') unless token.verify(code)

      delete_claim!
      WikiClient.create_page("Discord_verification:#{user.id}", current_verification)
      WikiClient.create_page("Discord_verification:#{wiki_username}", "#{user.id}\n[[Category:Discord Verifications]]")
      WikiClient.protect_page("Discord_verification:#{user.id}", "Discord Verification Bot File")
      WikiClient.protect_page("Discord_verification:#{wiki_username}", "Discord Verification Bot File")

      t('success', wiki_username: wiki_username)
    end

    private

    def current_verification
      return "#{wiki_username}\n[[Category:Discord Verifications]]" if current_verification_page.status == 404

      [wiki_username, current_verification_page.body].join("\n")
    end

    def current_verification_page
      WikiClient.get_page("Discord_verification:#{user.id}")
    end

    def token
      @token ||= ::DiscordBot::Commands::User::Token.new(user: user, wiki_user: wiki_username)
    end

    def delete_claim!
      WikiClient.delete_page("Discord_verification:#{user.id}-claim", 'Username already claimed.')
    end

    def already_claimed_message
      delete_claim!

      t('already_claimed', wiki_username: wiki_username, discord_id: existing_user_page.body.split("\n").first)
    end

    def already_claimed?
      existing_user_page.status == 200
    end

    def existing_user_page
      @existing_user_page ||= WikiClient.get_page("Discord_verification:#{wiki_username}")
    end

    def currently_claiming?
      ongoing_claim_page.status == 200
    end

    def wiki_username
      ongoing_claim_page.body.split("\n").first
    end

    def ongoing_claim_page
      @ongoing_claim_page ||= WikiClient.get_page("Discord_verification:#{user.id}-claim")
    end

    def code
      modal_values['code']
    end

    def modal_keys
      %w[code]
    end
  end
end
