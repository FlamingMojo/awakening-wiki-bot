# frozen_string_literal: true

class ImageRule
  class Matcher
    attr_reader :rule, :image_info
    private :rule, :image_info

    def initialize(rule:, image_info:)
      @rule = rule
      @image_info = image_info
    end

    def match?
      [
        match_min_width, match_min_height,
        match_max_width, match_max_height,
        match_format, match_ratio,
      ].all?
    end

    private

    def match_min_width
      return true unless rule.min_width

      image_info.width >= rule.min_width
    end

    def match_max_width
      return true unless rule.max_width

      image_info.width <= rule.max_width
    end

    def match_min_height
      return true unless rule.min_height

      image_info.height >= rule.min_height
    end

    def match_max_height
      return true unless rule.max_height

      image_info.height <= rule.max_height
    end

    def match_format
      return true unless rule.format

      image_info.format.to_s == rule.format.to_s
    end

    def match_ratio
      return true unless rule.ratio
      return false if image_info.width == 0
      configured_precision = [rule.ratio.to_s.split('.').last.length, 5].max

      (image_info.height.to_f / image_info.width.to_f).round(configured_precision) == rule.ratio
    end
  end
end
