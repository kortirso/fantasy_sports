# frozen_string_literal: true

module Cups
  class CreateService
    prepend ApplicationService

    ROUND_VALUES = {
      1 => { name: 'Final', teams_amount: 2 },
      2 => { name: '1/2', teams_amount: 4 },
      3 => { name: '1/4', teams_amount: 8 },
      4 => { name: '1/8', teams_amount: 16 },
      5 => { name: '1/16', teams_amount: 32 },
      6 => { name: '1/32', teams_amount: 64 },
      7 => { name: '1/64', teams_amount: 128 },
      8 => { name: '1/128', teams_amount: 256 },
      9 => { name: '1/256', teams_amount: 512 },
      10 => { name: '1/512', teams_amount: 1024 }
    }.freeze
    MAX_ROUNDS_AMOUNT = 10

    def initialize(max_rounds_amount: MAX_ROUNDS_AMOUNT)
      @max_rounds_amount = max_rounds_amount
    end

    def call(fantasy_league:)
      @fantasy_league = fantasy_league
      return if fantasy_league.cup

      ActiveRecord::Base.transaction do
        cup = fantasy_league.create_cup!(name: fantasy_league.name)
        create_cup_rounds(cup)
      end
    end

    private

    def create_cup_rounds(cup)
      rounds = []
      index = 1

      loop do
        week_id = cup_weeks.shift
        break unless week_id
        break if index > @max_rounds_amount
        break if ROUND_VALUES[index][:teams_amount] >= fantasy_teams_amount

        rounds.push({
          cup_id: cup.id,
          week_id: week_id,
          position: index,
          name: ROUND_VALUES[index][:name]
        })
        index += 1
      end

      Cups::Round.upsert_all(rounds) if rounds.any?
    end

    def cup_weeks
      @cup_weeks ||=
        @fantasy_league
        .season
        .weeks
        .where('position > ?', Weeks::StartService::GENERATE_WEEK_POSITION)
        .order(position: :desc)
        .pluck(:id)
    end

    def fantasy_teams_amount
      @fantasy_teams_amount ||= @fantasy_league.fantasy_teams.count
    end
  end
end
