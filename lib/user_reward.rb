# frozen_string_literal: true

class UserReward < ActiveRecord::Base
  enum :status, %i[pending approved]
  enum :issue_type, %i[missions staff manual]

  belongs_to :issuer, class_name: 'DiscordUser'
  belongs_to :reward
  has_one :reward_type, through: :reward
  belongs_to :discord_user

  after_initialize :cache_user, unless: :persisted?

  def award(issuer)
    update(issuer:, status: :approved)
  end

  def unclaim!
    reward.update(user_reward: nil)
    destroy
  end

  def cache_user
    update(discord_uid: discord_user.discord_uid, issued_at: Time.now)
  end

  def to_message
    "#{ '[STAFF] ' if staff? }#{reward_type.name} - `#{pending? ? 'PENDING APPROVAL' : reward.key}`"
  end

  def redacted
    "`#{reward.key[0..4]}********#{reward.key[-4..-1]}`"
  end

  def reward_key
    reward_type.reward_key
  end
end
