# frozen_string_literal: true

module Lineups
  class CreateService
    prepend ApplicationService

    def initialize(
      lineup_players_creator: Lineups::Players::CreateService,
      lineup_players_copier:  Lineups::Players::CopyService
    )
      @lineup_players_creator = lineup_players_creator
      @lineup_players_copier  = lineup_players_copier
    end

    def call(fantasy_team:, week: nil)
      @fantasy_team = fantasy_team
      @week = week || @fantasy_team.season.weeks.coming.first
      return if @week.nil?

      ActiveRecord::Base.transaction do
        create_lineup
        add_lineup_players
      end
    rescue ActiveRecord::RecordNotUnique
      fail!(I18n.t('services.lineups.create.record_exists'))
    end

    private

    def create_lineup
      params = { fantasy_team: @fantasy_team, week: @week, free_transfers_amount: free_transfers_per_week }
      params[:transfers_limited] = false if previous_lineup.nil?
      params[:free_transfers_amount] *= 2 if previous_lineup&.transfers&.size&.zero?

      @result = Lineup.create!(params)
    end

    def add_lineup_players
      return @lineup_players_creator.call(lineup: @result) if previous_lineup.nil?

      @lineup_players_copier.call(lineup: @result, previous_lineup: previous_lineup)
    end

    def previous_lineup
      @previous_lineup ||= @fantasy_team.lineups.find_by(week: @week.previous)
    end

    def free_transfers_per_week
      Sport.find_by(title: @week.season.league.sport_kind).free_transfers_per_week
    end
  end
end
