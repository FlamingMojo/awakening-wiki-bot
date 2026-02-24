# frozen_string_literal: true

class ImageMissionRule < ActiveRecord::Base
  belongs_to :mission
  belongs_to :image_rule
end
