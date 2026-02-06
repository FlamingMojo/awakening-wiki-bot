# frozen_string_literal: true

class WikiUser
  class LookupDiscordUser
    attr_reader :discord_uid
    private :discord_uid

    def initialize(discord_uid)
      @discord_uid = discord_uid
    end

    def lookup
      return existing_users if existing_users.any?
      return [] unless wiki_usernames

      wiki_usernames.map do |username|
        discord_user.wiki_users.find_or_create_by(username: username)
      end
    end

    def existing_users
      @existing_users ||= WikiUser.joins(:discord_user).where(discord_user: { discord_uid: discord_uid })
    end

    def discord_user
      @discord_user ||= DiscordUser.find_or_create_by(discord_uid: discord_uid)
    end

    def wiki_usernames
      verifications['verified']['discord'][discord_uid]
    end

    def verifications
      @verifications ||= JSON.parse(WikiClient.get_page('Discord_verification:all.json').body)
    end
  end
end
