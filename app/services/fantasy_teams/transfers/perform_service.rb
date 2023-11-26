# frozen_string_literal: true

module FantasyTeams
  module Transfers
    class PerformService
      prepend ApplicationService

      def initialize(
        transfers_validator: FantasyTeams::Players::TransfersValidator.new,
        fantasy_teams_update_points_service: FantasyTeams::Points::UpdateService
      )
        @transfers_validator = transfers_validator
        @fantasy_teams_update_points_service = fantasy_teams_update_points_service
      end

      # TODO: teams_players_ids probably contains player_ids
      def call(fantasy_team:, teams_players_ids:, only_validate: true)
        @fantasy_team = fantasy_team
        @existed_teams_players_ids = @fantasy_team.teams_players.ids
        @teams_players_ids = teams_players_ids

        return if validate_players && failure?
        return validation_response if only_validate

        make_transfers
        @result = I18n.t('services.fantasy_teams.transfers.perform.success')
      end

      private

      def removed_teams_players_ids
        @removed_teams_players_ids ||= @existed_teams_players_ids - @teams_players_ids
      end

      def removed_players
        @removed_players ||= ::Player.joins(:teams_players).where(teams_players: { id: removed_teams_players_ids })
      end

      def added_teams_players_ids
        @added_teams_players_ids ||= @teams_players_ids - @existed_teams_players_ids
      end

      def added_teams_players
        @added_teams_players ||= Teams::Player.where(id: added_teams_players_ids).hashable_pluck(:id, :player_id)
      end

      def added_players
        @added_players ||= ::Player.joins(:teams_players).where(teams_players: { id: added_teams_players_ids }).to_a
      end

      def validate_players
        fails!(
          @transfers_validator.call(
            fantasy_team: @fantasy_team,
            teams_players_ids: @teams_players_ids,
            budget_limit: @fantasy_team.teams_players.sum(:price_cents) + @fantasy_team.budget_cents
          )
        )
      end

      def validation_response
        @result = {
          out_names: removed_players.pluck(:name),
          in_names: added_players.pluck(:name),
          penalty_points: penalty_points
        }
      end

      def penalty_points
        @penalty_points ||= -1 * penalty_transfers_amount * points_per_transfer
      end

      def points_per_transfer
        Sport.find_by(title: @fantasy_team.sport_kind).points_per_transfer
      end

      def penalty_transfers_amount
        return 0 unless coming_lineup.transfers_limited?
        return 0 if removed_teams_players_ids.size <= free_transfers_amount_limit

        removed_teams_players_ids.size - free_transfers_amount_limit
      end

      def make_transfers
        ActiveRecord::Base.transaction do
          remove_fantasy_team_players
          create_removing_transfers
          add_fantasy_team_players
          create_adding_transfers
          update_fantasy_team
          update_fantasy_team_points
          update_lineup
          update_lineup_players
        end
      end

      def update_fantasy_team_points
        @fantasy_teams_update_points_service.call(fantasy_team_ids: [@fantasy_team.id])
      end

      def remove_fantasy_team_players
        @fantasy_team.fantasy_teams_players.where(teams_player_id: removed_teams_players_ids).destroy_all
      end

      def create_removing_transfers
        Transfer.upsert_all(
          removed_teams_players_ids.map { |teams_player_id|
            {
              teams_player_id: teams_player_id,
              lineup_id: coming_lineup.id,
              direction: Transfer::OUT
            }
          }
        )
      end

      def add_fantasy_team_players
        ::FantasyTeams::Player.upsert_all(
          added_teams_players_ids.map { |teams_player_id|
            { teams_player_id: teams_player_id, fantasy_team_id: @fantasy_team.id }
          }
        )
      end

      def create_adding_transfers
        Transfer.upsert_all(
          added_teams_players_ids.map { |teams_player_id|
            {
              teams_player_id: teams_player_id,
              lineup_id: coming_lineup.id,
              direction: Transfer::IN
            }
          }
        )
      end

      def update_fantasy_team
        @fantasy_team.update!(budget_cents: @fantasy_team.budget_cents + budget_change)
      end

      def budget_change
        price_of_removed_players = ::Teams::Player.where(id: removed_teams_players_ids).sum(:price_cents)
        price_of_added_players   = ::Teams::Player.where(id: added_teams_players_ids).sum(:price_cents)
        price_of_removed_players - price_of_added_players
      end

      def update_lineup
        left_transfers = free_transfers_amount_limit - removed_teams_players_ids.size
        coming_lineup.update!(
          free_transfers_amount: left_transfers.negative? ? 0 : left_transfers,
          penalty_points: coming_lineup.penalty_points + penalty_points
        )
      end

      def update_lineup_players
        lineups_players = coming_lineup.lineups_players.where(teams_player_id: removed_teams_players_ids)
        return if lineups_players.empty?

        create_lineups_players(lineups_players)
        lineups_players.destroy_all
      end

      def create_lineups_players(lineups_players)
        ::Lineups::Player.upsert_all(
          lineups_players.map { |lineups_player|
            generate_lineups_player(lineups_player)
          }
        )
      end

      def generate_lineups_player(lineups_player)
        selected_player = selected_player_for_position(lineups_player)
        @added_players.delete(selected_player)
        teams_player = added_teams_players.find { |element| element[:player_id] == selected_player.id }
        {
          teams_player_id: teams_player[:id],
          lineup_id: coming_lineup.id,
          change_order: lineups_player.change_order,
          status: lineups_player.status
        }
      end

      def selected_player_for_position(lineups_player)
        added_players.find { |player| player.position_kind == lineups_player.teams_player.player.position_kind }
      end

      def coming_lineup
        @coming_lineup ||= @fantasy_team.lineups.joins(:week).where(weeks: { status: Week::COMING }).first
      end

      def free_transfers_amount_limit
        @free_transfers_amount_limit ||= coming_lineup.free_transfers_amount
      end
    end
  end
end
