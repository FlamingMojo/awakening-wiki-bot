# frozen_string_literal: true

class ImageRule < ActiveRecord::Base
  include Subclasses

  has_many :image_rule_missions, dependent: :delete_all
  has_many :missions, through: :image_rule_missions

  def match(image_info)
    Matcher.new(rule: self, image_info: image_info).match?
  end
end
