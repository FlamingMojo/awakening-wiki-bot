# frozen_string_literal: true

class DiscordUser < ActiveRecord::Base
  include Subclasses
  has_many :wiki_users
  has_many :missions, foreign_key: 'assignee_id'
  has_many :issued_missions, foreign_key: 'issuer_id', class_name: 'Mission'
  has_many :user_rewards
  has_one :current_mission, -> { accepted }, class_name: 'Mission', foreign_key: 'assignee_id'

  def self.from_discord(user)
    find_or_create_by(discord_uid: user.id.to_s).tap { |u| u.update(username: user.username) }
  end

  def verify!(wiki_username)
    ::DiscordUser::Verify.new(discord_user: self, wiki_username:).verify!
  end

  def verified?(wiki_username)
    wiki_users.pluck(:username).include?(wiki_username)
  end

  def claimed_rewards
    user_rewards.approved.map(&:reward_key)
  end
end
