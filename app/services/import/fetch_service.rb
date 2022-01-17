# frozen_string_literal: true

module Import
  class FetchService
    prepend ApplicationService

    def initialize(
      instat_football_service: Import::Instat::Football::FetchService
    )
      @instat_football_service = instat_football_service
    end

    def call(args={})
      @result =
        case args
        in { source: Sourceable::INSTAT, sport_kind: Sportable::FOOTBALL }
          @instat_football_service.call(external_id: args[:external_id]).result
        end
    end
  end
end
