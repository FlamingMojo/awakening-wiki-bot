# frozen_string_literal: true

# Monkeypatch get_wikitext to allow URLs without the /w/ prefix.
class MediawikiApi::Client
  def get_wikitext(title)
    @conn.get '/index.php', action: 'raw', title: title
  end
end

class WikiClient
  def self.bot
    @bot ||= MediawikiApi::Client.new(ENV['WIKI_URL']).tap do |client|
      client.log_in(ENV['WIKI_BOT_USERNAME'], ENV['WIKI_BOT_PASSWORD'])
    end
  end

  def self.handle_command(method_name, *args, **kwargs)
    skip_retry = kwargs.delete(:skip_retry) || false
    bot.send(method_name, *args, **kwargs)

  rescue MediawikiApi::ApiError => e
    # The most common error is the 10min session timeout. Just re-log in and try again
    puts "WARNING: API Error. #{e}."
    return if skip_retry
    puts "\nRetrying..."
    bot.log_in(ENV['WIKI_BOT_USERNAME'], ENV['WIKI_BOT_PASSWORD'])
    bot.send(method_name, *args, **kwargs)
  end

  def self.query(*args, **kwargs)
    handle_command(:query, *args, **kwargs)
  end

  def self.protect_page(*args, **kwargs)
    handle_command(:protect_page, *args, **kwargs)
  end

  def self.delete_page(*args, **kwargs)
    handle_command(:delete_page, *args, **kwargs)
  end

  def self.create_page(*args, **kwargs)
    handle_command(:create_page, *args, **kwargs)
  end

  def self.get_page(*args, **kwargs)
    handle_command(:get_wikitext, *args, **kwargs)
  end

  def self.raw_action(*args, **kwargs)
    handle_command(:raw_action, *args, **kwargs)
  end

  def self.email_user(username:, subject:, text:)
    raw_action(:emailuser, target: username, subject: subject, text: text, skip_retry: true)
  end
end
