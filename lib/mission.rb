# frozen_string_literal: true

class Mission < ActiveRecord::Base
  include Subclasses
  include Translatable
  # Allow us to use the :type field.
  Mission.inheritance_column = nil

  # Add page_translate when ready
  TYPES = %w[page_create page_update image_upload].freeze

  with_locale_context 'mission'

  enum :status, %w[active accepted submitted completed].map { |k| [k.to_sym, k] }.to_h
  enum :priority, %w[low medium high].map { |k| [k, k] }.to_h
  enum :type, TYPES.map { |k| [k, k] }.to_h

  belongs_to :issuer, class_name: 'DiscordUser', required: true
  belongs_to :assignee, class_name: 'DiscordUser', optional: true
  has_one :image_mission_rule, dependent: :destroy
  has_one :image_rule, through: :image_mission_rule

  scope :in_progress, -> { where(status: %w[active accepted submitted]) }

  validates :wiki_page, format: { with: /\A#{ENV['WEBSITE_URL']}\//i, allow_blank: true }
  validates :map_link, format: { with: /\A#{ENV['WEBSITE_URL']}\//i, allow_blank: true }

  def context
    return :live if active? || accepted?
    return :archive if completed?

    :admin
  end

  def rule=(rule_name)
    return unless rule_name

    image_mission_rule = ImageMissionRule.new(mission: self, image_rule: ImageRule.find_by(name: rule_name))
  end

  def accept(discord_user)
    update(assignee: discord_user, status: 'accepted') && sync_post!
  end

  def submit
    delete_post! && submitted! && reload && sync_post!
  end

  def abandon
    delete_post! && update(assignee: nil, status: 'active') && reload && sync_post!
  end

  def cancel
    delete_post! && update(assignee: nil, status: 'completed', title: "[CANCELLED] #{title}") && reload && sync_post!
  end

  def reject
    delete_post! && accepted! && reload && sync_post!
  end

  def approve
    completed! && reload && sync_post!
  end

  def delete_post!
    return unless discord_post_uid

    post.delete && update(discord_post_uid: nil, discord_post_link: nil)
  end

  def sync_post!
    return post.update if discord_post_uid

    post_message = post.create
    update(
      discord_post_uid: post_message.id,
      discord_post_link: t('link', message_id: post_message.id, channel_id: post.channel)
    )
  end

  def embed
    Embed.generate(self)
  end

  def post
    Post.new(reload)
  end

  def display_attributes
    attributes.merge('wiki_page_md' => wiki_page_md, 'map_link_md' => map_link_md)
  end

  def wiki_page_md
    format_link(wiki_page)
  end

  def map_link_md
    format_link(map_link)
  end

  def format_link(link)
    return unless link
    "[#{link.split('/').last.split('?').first.gsub('_', ' ')}](#{link})"
  end

  def instructions
    params = display_attributes.slice(*I18n.interpolation_keys("mission.instructions.#{type}")).symbolize_keys
    t("instructions.#{type}",**params)
  end

  def summary
    "[#{id}] #{title}"
  end

  def channel_uid
    discord_post_link.gsub('https://discord.com/channels/','').split('/')[1]
  end
end
