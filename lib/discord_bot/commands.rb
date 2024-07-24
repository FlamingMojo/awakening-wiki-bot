# frozen_string_literal: true
require_relative 'util'

module DiscordBot
  module Commands
    # Just loads all of the command modules in the lib/discord_bot/commands directory
    include Subclasses
  end
end
