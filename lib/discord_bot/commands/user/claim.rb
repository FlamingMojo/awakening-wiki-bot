# frozen_string_literal: true
require_relative './token'

module DiscordBot::Commands::User
  class Claim
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.user.claim'

    def content
      return t('already_claimed', wiki_username: wiki_username, owner_id: existing_user_page.body) if already_claimed
      return t('ongoing_claim', ongoing_claim_username: ongoing_claim_username) if ongoing_claim
      t('failure') if send_email.nil?

      WikiClient.create_page("Discord_verification:#{user.id}-claim", claim_text)
      WikiClient.protect_page("Discord_verification:#{user.id}-claim", "Discord Verification Bot File")

      t('success', wiki_username: wiki_username)
    end

    def response_block
      return super if error?

      lambda do |_builder, view|
        view.row do |row|
          row.button(label: t('enter_code'), custom_id: 'claim:submit_token', style: :primary)
        end
      end
    end

    private

    def error?
      already_claimed || ongoing_claim || send_email.nil?
    end

    def send_email
      @send_email ||= WikiClient.email_user(
        username: wiki_username,
        subject: t('email.subject', token: token),
        text: t(
          'email.text',
          wiki_username: wiki_username,
          discord_username: user.username,
          discord_id: user.id,
          token: token
        ),
      )
    end

    def claim_text
      "#{wiki_username}\n[[Category:Discord Verifications]]"
    end

    def token
      @token ||= DiscordBot::Commands::User::Token.new(user: user, wiki_user: wiki_username).code
    end

    def already_claimed
      @already_claimed ||= existing_user_page.status == 200
    end

    def existing_user_page
      @existing_user_page ||= WikiClient.get_page("Discord_verification:#{wiki_username}")
    end

    def ongoing_claim_username
      ongoing_claim_page.body.split("\n").first
    end

    def ongoing_claim
      @ongoing_claim ||= ongoing_claim_page.status == 200 && ongoing_claim_username != wiki_username
    end

    def ongoing_claim_page
      @ongoing_claim_page ||= WikiClient.get_page("Discord_verification:#{user.id}-claim")
    end

    def wiki_username
      modal_values['wiki_username']
    end

    def modal_keys
      %w[wiki_username]
    end
  end
end
