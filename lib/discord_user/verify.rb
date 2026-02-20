class DiscordUser
  class Verify
    include Translatable

    with_locale_context 'discord_bot.commands.user.verify'

    attr_reader :discord_user, :wiki_username
    private :discord_user, :wiki_username

    def initialize(discord_user:, wiki_username:)
      @discord_user = discord_user
      @wiki_username = wiki_username
    end

    def verify!
      complete_verification!
      discord_user.wiki_users.find_or_create_by(username: wiki_username)

      DiscordBot.bot.send_message(ENV.fetch('DISCORD_UPDATE_FEED_CHANNEL_ID', ''), broadcast_message)
    end

    private

    def broadcast_message
      t('success', wiki_username:, user_id: discord_uid)
    end

    def complete_verification!
      currently_claiming.each { |k| verifications['ongoing']['discord'].delete(k) }
      verifications['verified']['wiki'][wiki_username] = discord_uid
      verifications['verified']['discord'][discord_uid] ||= []
      verifications['verified']['discord'][discord_uid] << wiki_username
      WikiClient.create_page('Discord_verification:all.json', verifications.to_json)
    end

    def discord_uid
      @discord_uid ||= discord_user.discord_uid
    end

    def currently_claiming
      @currently_claiming ||= verifications['ongoing']['discord'].select { |_k, v| v == wiki_username }.keys
    end

    def verifications
      @verifications ||= JSON.parse(WikiClient.get_page('Discord_verification:all.json').body)
    end
  end
end
