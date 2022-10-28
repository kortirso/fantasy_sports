# frozen_string_literal: true

module Import
  class FetchGameDataService
    prepend ApplicationService

    def call(external_id:, fetcher_service:)
      @result = fetcher_service.call(external_id: external_id).result
    end
  end
end
