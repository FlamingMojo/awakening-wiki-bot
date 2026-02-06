# frozen_string_literal: true
require_relative './token'

module DiscordBot::Commands::User
  class Claim
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.user.claim'

    def content
      return t('already_claimed', wiki_username: wiki_username, owner_id: existing_user) if existing_user
      return t('ongoing_claim', ongoing_claim_username: ongoing_claim) if ongoing_claim

      verifications['ongoing']['discord'][user.id.to_s] = wiki_username
      WikiClient.create_page('Discord_verification:all.json', verifications.to_json)

      t('instructions', wiki_username: wiki_username, token: token)
    end

    private

    def claim_text
      "#{wiki_username}\n[[Category:Discord Verifications]]"
    end

    def token
      @token ||= DiscordBot::Commands::User::Token.new(user: user, wiki_user: wiki_username).code
    end

    def existing_user
      verifications['verified']['wiki']['wiki_username']
    end

    def ongoing_claim
      verifications['ongoing']['discord'][user.id.to_s]
    end

    def verifications
      @verifications ||= JSON.parse(WikiClient.get_page('Discord_verification:all.json').body)
    end

    def wiki_username
      modal_values['wiki_username'].gsub(' ', '_')
    end

    def modal_keys
      %w[wiki_username]
    end
  end
end
