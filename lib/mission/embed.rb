# frozen_string_literal: true

class Mission
  class Embed
    include Translatable

    with_locale_context 'mission.embed'

    THUMBNAILS = {
      page_create: 'https://media.awakening.wiki/wiki/b/b8/T_UI_IconMapLore_D.png',
      page_update: 'https://media.awakening.wiki/wiki/8/81/T_UI_IconMapMarkerContract_D.png',
      image_upload: 'https://media.awakening.wiki/wiki/f/f8/T_UI_IconMapMarkerLoot_D.png',
      page_translate: 'https://media.awakening.wiki/wiki/8/8b/T_UI_IconMapDynamicEventsRumor_D.png',
    }.freeze

    COLOURS = {
      active: 0x8ff0a4,
      accepted: 0xffbe6f,
      submitted: 0xf9f06b,
      completed: 0x99c1f1,
    }.freeze

    attr_reader :mission

    def initialize(mission)
      @mission = mission
    end

    def self.generate(mission)
      new(mission).generate
    end

    def generate
      embed.title = mission.summary
      embed.colour = COLOURS.fetch(mission.status.to_sym)
      embed.description = mission.description
      embed.timestamp = Time.now
      embed.thumbnail = thumbnail
      embed.add_field(name: t('field.instructions'), value: mission.instructions, inline: true)
      embed.add_field(name: t('field.status'), value: mission.status.titleize, inline: true)
      embed.add_field(name: t('field.issuer'), value: "<@#{mission.issuer.discord_uid}>", inline: true)
      embed.add_field(name: t('field.wiki_page'), value: mission.wiki_page_md, inline: true) if mission.wiki_page?
      embed.add_field(name: t('field.map_link'), value: mission.map_link_md, inline: true) if mission.map_link?
      embed.add_field(name: t('field.language'), value: mission.language, inline: true) if mission.language?
      embed.add_field(name: t('field.assignee'), value: assignee)

      embed
    end

    def assignee
      return t('no_assignee') unless mission.assignee

      "<@#{mission.assignee.discord_uid}>"
    end

    def type
      @type ||= mission.type.to_sym
    end

    def thumbnail
      Discordrb::Webhooks::EmbedThumbnail.new(url: THUMBNAILS.fetch(type))
    end

    def embed
      @embed ||= Discordrb::Webhooks::Embed.new
    end
  end
end
