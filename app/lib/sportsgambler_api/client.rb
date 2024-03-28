# frozen_string_literal: true

module SportsgamblerApi
  class Client < HttpService::Client
    include Requests::Injuries

    BASE_URL = 'https://www.sportsgambler.com'

    option :url, default: proc { BASE_URL }
  end
end
