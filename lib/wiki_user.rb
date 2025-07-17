# frozen_string_literal: true

class WikiUser < ActiveRecord::Base
  include Subclasses
  belongs_to :discord_user

  def self.lookup(discord_uid)
    LookupDiscordUser.new(discord_uid).lookup
  end
end
