# frozen_string_literal: true

module TelegramApi
  module Requests
    module Messages
      def send_message(bot_secret:, chat_id:, text:)
        get(
          path: URI.parse(URI::Parser.new.escape("bot#{bot_secret}/sendMessage?chat_id=#{chat_id}&text=#{text}")).to_s,
          headers: headers
        )
      end
    end
  end
end
