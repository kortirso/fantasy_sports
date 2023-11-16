# frozen_string_literal: true

module Lineups
  class BenchSubstitutionsService
    prepend ApplicationService

    def initialize(
      lineups_players_update_points_service: Lineups::Players::Points::UpdateService
    )
      @lineups_players_update_points_service = lineups_players_update_points_service
      @lineups_players_for_update = []
      @team_player_ids = []
    end

    def call(week:)
      return unless Sport.find_by(title: week.league.sport_kind).changes

      @week = week
      @week.lineups.each do |lineup|
        @lineup = lineup
        prepare_bench_substitutions
        check_captain_change
      end
      make_bench_substitutions
      update_points_for_lineups_players
    end

    private

    def prepare_bench_substitutions
      return if players_to_substitute.blank?
      return if available_bench_players.blank?

      until @available_bench_players.blank?
        available_bench_player = @available_bench_players.shift

        player_for_change = find_player_for_change(available_bench_player)
        next if player_for_change.nil?

        add_players_for_update(player_for_change, available_bench_player)
      end
    end

    def check_captain_change
      return unless captain_without_minutes
      return unless assistant_with_minutes

      set_status_for_player(captain_without_minutes, Lineups::Player::ASSISTANT)
      set_status_for_player(assistant_with_minutes, Lineups::Player::CAPTAIN)
    end

    def make_bench_substitutions
      return if @lineups_players_for_update.blank?

      Lineups::Player.upsert_all(
        @lineups_players_for_update,
        record_timestamps: true
      )
    end

    def update_points_for_lineups_players
      return if @team_player_ids.blank?

      @lineups_players_update_points_service.call(
        team_player_ids: @team_player_ids.uniq,
        week_id: @week.id
      )
    end

    def find_player_for_change(available_bench_player)
      position_kind = available_bench_player[1]

      # if lineup has player for substitution at the same position - use that player for change
      same_position_players = substitution_for_position(position_kind)
      return same_position_players if same_position_players
      # if lineup has maximum amount of position players - bench_player can not be added to lineup
      return if maximum_players_at_position?(position_kind)

      # check other positions
      other_positions(position_kind).each do |sport_position|
        # if lineup has minimum amount of position players - they can not be used for changes
        next if minimum_players_at_position?(sport_position.title)

        position_player = substitution_for_position(sport_position.title)
        return position_player if position_player
      end
    end

    def set_status_for_player(lineups_player, status)
      existing_record = @lineups_players_for_update.find { |e| e[:id] == lineups_player[0].id }
      if existing_record
        existing_record[:status] = status
      else
        @team_player_ids.push(lineups_player[0].teams_player_id)
        push_player_to_update(lineups_player, nil, status)
      end
    end

    def add_players_for_update(player_for_change, available_bench_player)
      @players_to_substitute.delete(player_for_change)

      @team_player_ids.push(player_for_change[0].teams_player_id)
      @team_player_ids.push(available_bench_player[0].teams_player_id)
      push_player_to_update(player_for_change, available_bench_player[0].change_order)
      push_player_to_update(available_bench_player, 0)
    end

    def push_player_to_update(lineups_player, change_order=nil, status=nil)
      @lineups_players_for_update.push(
        {
          id: lineups_player[0].id,
          lineup_id: lineups_player[0].lineup_id,
          teams_player_id: lineups_player[0].teams_player_id,
          change_order: change_order || lineups_player[0].change_order,
          status: status || lineups_player[0].status
        }
      )
    end

    def lineup_players
      @lineup_players =
        @lineup
        .lineups_players
        .where(change_order: 0)
        .includes(teams_player: :player)
        .map { |lineups_player|
          [
            lineups_player,
            lineups_player.teams_player.player.position_kind,
            minutes_played(lineups_player)
          ]
        }
    end

    def players_to_substitute
      @players_to_substitute =
        lineup_players
        .select { |lineup_player| lineup_player[2].zero? }
    end

    def available_bench_players
      @available_bench_players =
        @lineup
        .lineups_players
        .where.not(change_order: 0)
        .includes(teams_player: :player)
        .order(change_order: :asc)
        .filter_map { |lineups_player|
          next if minutes_played(lineups_player).zero?

          [
            lineups_player,
            lineups_player.teams_player.player.position_kind
          ]
        }
    end

    def captain_without_minutes
      @lineup_players.find { |e| e[0].status == Lineups::Player::CAPTAIN && e[2].zero? }
    end

    def assistant_with_minutes
      @lineup_players.find { |e| e[0].status == Lineups::Player::ASSISTANT && e[2].positive? }
    end

    def minutes_played(lineups_player)
      lineups_player.statistic[Statable::MP].presence || 0
    end

    def sport_positions
      @sport_positions ||= Sports::Position.where(sport: @week.league.sport_kind).to_a
    end

    def other_positions(position_kind)
      sport_positions.reject { |e| e.title == position_kind }
    end

    def substitution_for_position(position_kind)
      @players_to_substitute.find { |e| e[1] == position_kind }
    end

    def maximum_players_at_position?(position_kind)
      @lineup_players.count { |e| e[1] == position_kind } == max_game_amount(position_kind)
    end

    def minimum_players_at_position?(position_kind)
      @lineup_players.count { |e| e[1] == position_kind } == min_game_amount(position_kind)
    end

    def max_game_amount(position_kind)
      sport_positions.find { |e| e.title == position_kind }.max_game_amount
    end

    def min_game_amount(position_kind)
      sport_positions.find { |e| e.title == position_kind }.min_game_amount
    end
  end
end
