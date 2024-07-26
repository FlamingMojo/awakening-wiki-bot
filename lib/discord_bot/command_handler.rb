# frozen_string_literal: true

module DiscordBot
  module CommandHandler
    def handle(command, subcommand, service)
      DiscordBot.bot.application_command(command).subcommand(subcommand) do |event|
        EventHandler.new(event: event, service: const_get(service)).respond
      end
    end

    def handle_command(command, service)
      DiscordBot.bot.application_command(command) do |event|
        EventHandler.new(event: event, service: const_get(service)).respond
      end
    end

    def handle_button(custom_id, service)
      DiscordBot.bot.button(custom_id: custom_id) do |event|
        EventHandler.new(event: event, service: const_get(service)).respond
      end
    end

    def handle_select_menu(custom_id, service)
      DiscordBot.bot.select_menu(custom_id: custom_id) do |event|
        EventHandler.new(event: event, service: const_get(service)).respond
      end
    end

    def handle_role_select(custom_id, service)
      DiscordBot.bot.role_select(custom_id: custom_id) do |event|
        DiscordBot::EventHandler.new(event: event, service: const_get(service)).respond
      end
    end

    def handle_modal(custom_id, service)
      DiscordBot.bot.modal_submit(custom_id: custom_id) do |event|
        EventHandler.new(event: event, service: const_get(service)).respond
      end
    end

    # handle_group(:example, :fun, { one: 'OneService', two: 'TwoService'... })
    def handle_group(command, group_name, subcommands)
      DiscordBot.bot.application_command(command).group(group_name) do |group|
        subcommands.each do |subcommand, service|
          group.subcommand(subcommand) do |event|
            EventHandler.new(event: event, service: const_get(service)).respond
          end
        end
      end
    end

    class EventHandler
      extend Forwardable
      attr_reader :event, :service
      private :event, :service

      def initialize(event:, service:)
        @event = event
        @service = service
      end

      def respond
        # Response_method is either respond or update_message
        # Response_params calls the service to perform the actions
        # Response_block is an optional block to build action rows
        event.send(response_method, **response_params, &response_block)
      end

      private

      def handler
        @handler ||= service.new(event)
      end
      def_delegators :handler, :response_method, :response_params, :response_block, :after_response
    end
  end
end

