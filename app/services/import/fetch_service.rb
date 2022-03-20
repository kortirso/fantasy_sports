# frozen_string_literal: true

module Import
  class FetchService
    prepend ApplicationService

    def initialize(
      instat_football_service: Import::Instat::Football::FetchService,
      balldontlie_baskterball_service: Import::Balldontlie::Basketball::FetchService
    )
      @instat_football_service = instat_football_service
      @balldontlie_baskterball_service = balldontlie_baskterball_service
    end

    def call(args={})
      @result =
        case args
        in { source: Sourceable::INSTAT, sport_kind: Sportable::FOOTBALL }
          @instat_football_service.call(external_id: args[:external_id]).result
        in { source: Sourceable::BALLDONTLIE, sport_kind: Sportable::BASKETBALL }
          @balldontlie_baskterball_service.call(external_id: args[:external_id]).result
        end
    end
  end
end
