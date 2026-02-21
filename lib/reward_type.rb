# frozen_string_literal: true

class RewardType < ActiveRecord::Base
  enum :reward_key, %i[atreides_battle_rifle]
  enum :threshold_type, %i[mission_count]

  scope :active, ->{ where(active: true) }

  has_many :rewards, inverse_of: :reward_type, dependent: :nullify

  def in_stock?
    rewards.unclaimed.any?
  end

  def next_reward
    rewards.unclaimed.first
  end
end
