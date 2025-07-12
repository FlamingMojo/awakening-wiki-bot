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
      return [] if wiki_usernames_page.status == 404

      wiki_usernames.map do |username|
        WikiUser.create(username: username, discord_user: discord_user)
      end
    end

    def existing_users
      @existing_users ||= WikiUser.joins(:discord_user).where(discord_user: { discord_uid: discord_uid })
    end

    def discord_user
      @discord_user ||= DiscordUser.find_or_create_by(discord_uid: discord_uid)
    end

    def wiki_usernames
      # The last line of the verification is the category, which we can ignore.
      wiki_usernames_page.body.split("\n")[...-1]
    end

    def wiki_usernames_page
      WikiClient.get_page("Discord_verification:#{discord_uid}")
    end
  end
end
