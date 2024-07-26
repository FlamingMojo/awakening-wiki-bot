# frozen_string_literal: true

require 'base32'
require 'digest'
require 'discordrb'
require 'dotenv'
require 'forwardable'
require 'i18n'
require 'json'
require 'mediawiki_api'
require 'rotp'
require 'yaml'

Dotenv.load

I18n.load_path += Dir[File.expand_path("config/locales") + "/*.yml"]
I18n.default_locale = :en

# Monkey patch this fix in as Discord changed their API without warning to no longer accept {} as a nil emoji as of
# 05-01-2024. Discordrb version <= 3.5.0.
class Discordrb::Webhooks::View
  class RowBuilder
    def button(style:, label: nil, emoji: nil, custom_id: nil, disabled: nil, url: nil)
      style = BUTTON_STYLES[style] || style

      emoji = case emoji
              when Integer, String
                emoji.to_i.positive? ? { id: emoji } : { name: emoji }
              when nil
                nil
              else
                emoji.to_h
              end

      @components << { type: COMPONENT_TYPES[:button], label: label, emoji: emoji, style: style, custom_id: custom_id, disabled: disabled, url: url }
    end
  end

  class SelectMenuBuilder
    def option(label:, value:, description: nil, emoji: nil, default: nil)
      emoji = case emoji
              when Integer, String
                emoji.to_i.positive? ? { id: emoji } : { name: emoji }
              when nil
                nil
              else
                emoji.to_h
              end

      @options << { label: label, value: value, description: description, emoji: emoji, default: default }
    end
  end
end


module Translatable
  module DSL
    def with_locale_context(prefix)
      define_singleton_method :locale_context, ->{ @locale_context ||= prefix }
    end

    def locale_context
      @locale_context ||= ''
    end

    def t(key, *args, **kwargs)
      full_key = "#{self.locale_context}.#{key}"
      env_interpolations = ENV.to_h.slice(*I18n.interpolation_keys(full_key)).transform_keys(&:to_sym)
      I18n.t(full_key, *args, **env_interpolations.merge(kwargs))
    end
  end

  def self.included(base)
    # Allow including class to use the DSL
    # with_locale_context 'top.level.i18n.keys'
    base.extend(DSL)
  end

  def t(key, *args, **kwargs)
    # Allow t() to be used as an instance method - it's a shorthand, after all.
    self.class.t(key, *args, **kwargs)
  end
end

module Subclasses
  def self.included(base)
    # Hacky af but autoloads all files under a directory of the same name for subclasses
    Dir["#{caller[0].split(':')[0].gsub('.rb', '')}/*.rb"].each { |file| require file }
  end
end

Dir["./lib/*.rb"].each {|file| require file }
