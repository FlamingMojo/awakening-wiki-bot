# frozen_string_literal: true

module DiscordBot
  module CommandHandler
    def handle(command, subcommand, service, defer: true)
      DiscordBot.bot.application_command(command).subcommand(subcommand) do |event|
        EventHandler.new(event: event, service: const_get(service), defer: defer).respond
      end
    end

    def handle_command(command, service, defer: true)
      DiscordBot.bot.application_command(command) do |event|
        EventHandler.new(event: event, service: const_get(service), defer: defer).respond
      end
    end

    def handle_button(custom_id, service, defer: true)
      DiscordBot.bot.button(custom_id: custom_id) do |event|
        EventHandler.new(event: event, service: const_get(service), defer: defer).respond
      end
    end

    def handle_select_menu(custom_id, service, defer: true)
      DiscordBot.bot.select_menu(custom_id: custom_id) do |event|
        EventHandler.new(event: event, service: const_get(service), defer: defer).respond
      end
    end

    def handle_user_select(custom_id, service, defer: true)
      DiscordBot.bot.user_select(custom_id: custom_id) do |event|
        EventHandler.new(event: event, service: const_get(service), defer: defer).respond
      end
    end

    def handle_role_select(custom_id, service, defer: true)
      DiscordBot.bot.role_select(custom_id: custom_id) do |event|
        DiscordBot::EventHandler.new(event: event, service: const_get(service), defer: defer).respond
      end
    end

    def handle_modal(custom_id, service, defer: true)
      DiscordBot.bot.modal_submit(custom_id: custom_id) do |event|
        EventHandler.new(event: event, service: const_get(service), defer: defer).respond
      end
    end

    # handle_group(:example, :fun, { one: 'OneService', two: 'TwoService'... })
    def handle_group(command, group_name, subcommands, defer: true)
      DiscordBot.bot.application_command(command).group(group_name) do |group|
        subcommands.each do |subcommand, service|
          group.subcommand(subcommand) do |event|
            EventHandler.new(event: event, service: const_get(service), defer: defer).respond
          end
        end
      end
    end

    def handle_reaction(service, **attributes)
      DiscordBot.bot.reaction_add(attributes) do |event|
        const_get(service).new(event).handle
      end
    end

    def handle_message(service, **attributes)
      DiscordBot.bot.message(attributes) do |event|
        const_get(service).new(event).handle
      end
    end

    def handle_mention(service, **attributes)
      DiscordBot.bot.mention(attributes) do |event|
        const_get(service).new(event).handle
      end
    end

    class EventHandler
      extend Forwardable
      attr_reader :event, :service, :defer
      private :event, :service, :defer

      def initialize(event:, service:, defer: false)
        @event = event
        @service = service
        @defer = defer
      end

      def respond
        if defer && response_method != :show_modal
          # Optional defer to send a quick response and update later.
          event.interaction.defer
          event.interaction.send_message(**response_params, &response_block)
        else
          # Response_method is either respond or update_message
          # Response_params calls the service to perform the actions
          # Response_block is an optional block to build action rows
          event.send(response_method, **response_params, &response_block)
        end
      end

      private

      def handler
        @handler ||= service.new(event)
      end
      def_delegators :handler, :response_method, :response_params, :response_block, :after_response
    end
  end
end
