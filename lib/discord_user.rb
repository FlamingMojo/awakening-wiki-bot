# frozen_string_literal: true

class DiscordUser < ActiveRecord::Base
  has_many :wiki_users
  has_many :missions, foreign_key: 'assignee_id'
  has_many :issued_missions, foreign_key: 'issuer_id'
  has_one :current_mission, -> { accepted }, class_name: 'Mission', foreign_key: 'assignee_id'

  def self.from_discord(user)
    find_or_create_by(discord_uid: user.id.to_s).tap { |u| u.update(username: user.username) }
  end
end
