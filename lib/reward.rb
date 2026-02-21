# frozen_string_literal: true

class Reward < ActiveRecord::Base
  ImmutableKeyError = Class.new(StandardError)
  belongs_to :reward_type
  belongs_to :user_reward, optional: true
  has_one :discord_user, through: :user_reward, source: :discord_user

  scope :unclaimed, -> { where(user_reward_id: nil) }
  scope :claimed, -> { where.not(user_reward_id: nil) }

  def key=(new_key)
    raise ImmutableKeyError if self.encrypted_key

    self.encrypted_key = SymmetricEncryption.encrypt(new_key)
  end

  def key
    SymmetricEncryption.decrypt(self.encrypted_key)
  end

  def issue_to(discord_user, **kwargs)
    transaction do
      user_reward = UserReward.create!(reward: self, discord_user:, **kwargs)
      update(user_reward:)
    end
    user_reward
  end
end
