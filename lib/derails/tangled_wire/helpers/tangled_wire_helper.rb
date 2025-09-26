# frozen_string_literal: true

# :markup: markdown

module TangledWire
  module Helpers
    module TangledWireHelper
      # Returns an "action-cable-url" meta tag with the value of the URL specified in
      # your configuration. Ensure this is above your JavaScript tag:
      #
      #     <head>
      #       <%= tangled_wire_meta_tag %>
      #       <%= javascript_include_tag 'application', 'data-turbo-track' => 'reload' %>
      #     </head>
      #
      # This is then used by Action Cable to determine the URL of your WebSocket
      # server. Your JavaScript can then connect to the server without needing to
      # specify the URL directly:
      #
      #     import Cable from "@rails/actioncable"
      #     window.Cable = Cable
      #     window.App = {}
      #     App.cable = Cable.createConsumer()
      #
      # Make sure to specify the correct server location in each of your environment
      # config files:
      #
      #     config.tangled_wire.mount_path = "/cable123"
      #     <%= tangled_wire_meta_tag %> would render:
      #     => <meta name="action-cable-url" content="/cable123" />
      #
      #     config.tangled_wire.url = "ws://actioncable.com"
      #     <%= tangled_wire_meta_tag %> would render:
      #     => <meta name="action-cable-url" content="ws://actioncable.com" />
      #
      def tangled_wire_meta_tag
        tag "meta", name: "action-cable-url", content: (
          TangledWire.server.config.url ||
          TangledWire.server.config.mount_path ||
          raise("No Action Cable URL configured -- please configure this at config.tangled_wire.url")
        )
      end
    end
  end
end
