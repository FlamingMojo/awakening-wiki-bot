# frozen_string_literal: true

# Invoked from selecting mission type from Init
# Returns a new modal to create mission
module DiscordBot::Commands::Missions
  class New
    include Translatable
    include ::DiscordBot::Util

    with_locale_context 'discord_bot.commands.missions.new'

    def response_params
      { title: t('title', type: t(type)), custom_id: "mission:create:#{type}" }
    end

    def response_method
      :show_modal
    end

    def response_block
      lambda do |modal|
        %i[title description wiki_page map_link].each do |field|
          modal.row do |row|
            row.text_input(
              **{
                style: :short,
                custom_id: field,
                label: t("label.#{field}"),
                placeholder: t("placeholder.#{field}"),
                required: false,
              }.merge(field_settings.fetch(field, {}))
            )
          end
        end
      end
    end

    def field_settings
      {
        title: { required: true },
        description: { required: true, style: :paragraph, value: t("value.description.#{type}") },
      }.merge(type_settings.fetch(type.to_sym, {}))
    end

    def type_settings
      {
        page_create: { wiki_page: { required: true } },
        page_update: { wiki_page: { required: true } },
        page_translate: { wiki_page: { required: true }, language: { required: true } }
      }
    end

    def type
      event.values.first
    end
  end
end
