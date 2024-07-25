# frozen_string_literal: true
require_relative './token'

module DiscordBot::Commands::User
  class Claim
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.user.claim'

    def content
      return t('already_claimed', wiki_username: wiki_username, owner_id: existing_user_page.body) if already_claimed?
      return t('ongoing_claim', ongoing_claim_username: ongoing_claim_username) if ongoing_claim?
      return t('failure') unless send_email

      WikiClient.create_page("Discord_verification:#{user.id}-claim", wiki_username)
      WikiClient.protect_page("Discord_verification:#{user.id}-claim", "Discord Verification Bot File")

      t('success', wiki_username: wiki_username)
    end

    private

    def send_email
      WikiClient.email_user(
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

    def token
      @token ||= DiscordBot::Commands::User::Token.new(user: user, wiki_user: wiki_username).code
    end

    def already_claimed?
      existing_user_page.status == 200
    end

    def existing_user_page
      @existing_user_page ||= WikiClient.get_page("Discord_verification:#{wiki_username}")
    end

    def ongoing_claim_username
      ongoing_claim_page.body
    end

    def ongoing_claim?
      ongoing_claim_page.status == 200 && ongoing_claim_username != wiki_username
    end

    def ongoing_claim_page
      @ongoing_claim_page ||= WikiClient.get_page("Discord_verification:#{user.id}-claim")
    end

    def wiki_username
      event.options['wiki_username']
    end
  end
end
