# frozen_string_literal: true

require 'dry/initializer'

module HttpService
  class Client
    extend Dry::Initializer[undefined: false]

    option :url
    option :connection, default: proc { build_connection }

    def get(path:, params: {}, headers: {})
      response = connection.get(path) do |request|
        params.each { |param, value| request.params[param] = value }
        headers.each { |header, value| request.headers[header] = value }
      end
      response.body if response.success?
    end

    def post(path:, body: {}, params: {}, headers: {})
      response = connection.post(path) do |request|
        params.each { |param, value| request.params[param] = value }
        headers.each { |header, value| request.headers[header] = value }
        request.body = body.to_json
      end
      response.body if response.success?
    end

    private

    def build_connection
      Faraday.new(@url) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
