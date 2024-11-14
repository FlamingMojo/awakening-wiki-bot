# frozen_string_literal: true

# Monkeypatch get_wikitext to allow URLs without the /w/ prefix.
class MediawikiApi::Client
  def get_wikitext(title, *args, **kwargs)
    @conn.get '/index.php', action: 'raw', title: title, **kwargs
  end
end

class WikiClient
  include Subclasses

  attr_reader :url, :username, :password
  private :url, :username, :password

  def initialize(url: ENV['WIKI_URL'], username: ENV['WIKI_BOT_USERNAME'], password: ENV['WIKI_BOT_PASSWORD'])
    @url = url
    @username = username
    @password = password
  end

  def bot
    @bot ||= MediawikiApi::Client.new(url).tap do |client|
      client.log_in(username, password)
    end
  end

  def handle_command(method_name, *args, **kwargs)
    skip_retry = kwargs.delete(:skip_retry) || false
    bot.send(method_name, *args, **kwargs)
  rescue MediawikiApi::ApiError => e
    # The most common error is the 10min session timeout. Just re-log in and try again
    puts "WARNING: API Error. #{e}."
    return if skip_retry
    puts "\nRetrying..."
    bot.log_in(username, password)
    bot.send(method_name, *args, **kwargs)
  end

  def query(*args, **kwargs)
    handle_command(:query, *args, **kwargs)
  end

  def protect_page(*args, **kwargs)
    handle_command(:protect_page, *args, **kwargs)
  end

  def delete_page(*args, **kwargs)
    handle_command(:delete_page, *args, **kwargs)
  end

  def create_page(*args, **kwargs)
    handle_command(:create_page, *args, **kwargs)
  end

  def get_page(*args, **kwargs)
    handle_command(:get_wikitext, *args, **kwargs)
  end

  def raw_action(*args, **kwargs)
    handle_command(:raw_action, *args, **kwargs)
  end

  def upload_image(*args, **kwargs)
    # upload_image(filename, path, comment, ignorewarnings, text = nil)
    handle_command(:upload_image, *args, **kwargs)
  end

  def email_user(username:, subject:, text:)
    raw_action(:emailuser, target: username, subject: subject, text: text, skip_retry: true)
  end

  def self.handle_command(method_name, *args, **kwargs)
    new.handle_command(method_name, *args, **kwargs)
  end

  def self.query(*args, **kwargs)
    new.query(*args, **kwargs)
  end

  def self.protect_page(*args, **kwargs)
    new.protect_page(*args, **kwargs)
  end

  def self.delete_page(*args, **kwargs)
    new.delete_page(*args, **kwargs)
  end

  def self.create_page(*args, **kwargs)
    new.create_page(*args, **kwargs)
  end

  def self.get_page(*args, **kwargs)
    new.get_page(*args, **kwargs)
  end

  def self.raw_action(*args, **kwargs)
    new.raw_action(*args, **kwargs)
  end

  def self.upload_image(*args, **kwargs)
    # upload_image(filename, path, comment, ignorewarnings, text = nil)
    new.upload_image(*args, **kwargs)
  end

  def self.email_user(username:, subject:, text:)
    new.email_user(username: username, subject: subject, text: text)
  end
end
