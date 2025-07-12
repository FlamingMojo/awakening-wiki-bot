# frozen_string_literal: true

module DiscordBot
  include Subclasses

  # Wrap the Discordrb::Bot in a module
  def self.run(*args)
    bot.run(*args)
  end

  # Note - calling Bot.new does initialize the bot (goes calling off to Discord)
  def self.bot
    @bot ||= Discordrb::Bot.new(
      token: ENV['DISCORD_BOT_TOKEN'],
      client_id: ENV['DISCORD_CLIENT_ID'],
      log_mode: log_mode,
    )
  end

  def self.slash_command(*args, **kwargs, &block)
    bot.register_application_command(*args, **kwargs.merge(server_id: ENV['DISCORD_SERVER_ID']), &block)
  end

  def self.server
    @server ||= DiscordBot.bot.server(ENV['DISCORD_SERVER_ID'])
  end

  def self.send_message(*args, **kwargs)
    bot.send_message(*args, **kwargs)
  end

  def get_user(user_id)
    bot.user(user_id)
  end

  def pm_channel(user_id)
    get_user(user_id).pm
  end

  def self.log_mode
    ENV['BOT_ENV'] == 'production' ? :normal : :debug
  end

  def self.setup
    Dir['./lib/discord_bot/*.rb'].each { |file| require file }
    command_modules.each(&:setup)
  end

  # This filters all sub-modules to find ones setting up discord application commands
  def self.command_modules
    modules.select do |constant|
      constant.singleton_class.included_modules.include?(::DiscordBot::CommandHandler)
    end
  end

  def self.modules
    Commands.constants.map { |sym| self.const_get("Commands::#{sym}") }
  end
end
