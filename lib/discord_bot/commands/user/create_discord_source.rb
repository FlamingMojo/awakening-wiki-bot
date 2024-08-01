# frozen_string_literal: true
require 'securerandom'

module DiscordBot::Commands::User
  class CreateDiscordSource
    include Translatable
    include ::DiscordBot::Util

    InvalidImage = Class.new(StandardError)

    def content
      upload_image!

      WikiClient.create_page('Sources:Discord_Messages', new_page)
      "Discord Source #{id} Added successfully"
    rescue StandardError => e
      "Something went wrong #{e.message[..1000]}"
    end

    private

    def upload_image!
      generate_image_file!

      WikiClient.upload_image(
        image_filename,
        "./#{image_filename}",
        "Discord Message source for ##{id}",
        true, modal_values['text']
      )
    end

    def new_page
      # Hacky way to do it, but the table ends with a placeholder row. We can insert the new content before that row
      sections = current_page.split('<!-- Table Data -->')

      [sections.first, "#{sections[1]}<!-- Row -->\n#{new_source}", sections.last].join("<!-- Table Data -->")
    end

    def new_source
      <<~SRC
        <!-- Row -->
        {{Discord_Message_Source
        | id = #{id}
        | date = #{DateTime.parse(modal_values['date'].strip).strftime('%Y-%m-%d')}
        | author = #{modal_values['author']}
        | link = #{modal_values['link']}
        | text = #{modal_values['text']}
        | image = #{image_filename}
        }}
      SRC
    end

    def id
      @id ||= latest_id + 1
    end

    def image_filename
      @image_filename ||= "discord_source-#{id}-#{SecureRandom.hex}.png"
    end

    def generate_image_file!
      raise InvalidImage.new("Image must be png format") unless image_response.headers['content-type'] == 'image/png'

      File.open("./#{image_filename}", 'wb') { |fp| fp.write(image_response.body) }
    end

    def image_response
      @image_response ||= Faraday.get(modal_values['image_url'])
    end

    def latest_id
      # Could probably be done via Regex, but basically getting the `id = X`
      parse_row(existing_rows.last)['id'].to_i
    end

    def parse_row(row)
      Hash[
        row.strip.gsub('|', '').split("\n")[1...-1].map do |line|
          line.split('=', 2).map(&:strip)
        end
      ]
    end

    def existing_rows
      current_page.split('<!-- Table Data -->')[1].split('<!-- Row -->')
    end

    def current_page
      @current_page ||= WikiClient.get_page('Sources:Discord_Messages').body
    end

    def modal_keys
      %w[date author link text image_url]
    end
  end
end
