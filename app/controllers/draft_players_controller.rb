# frozen_string_literal: true

class DraftPlayersController < ApplicationController
  before_action :find_seasons
  before_action :find_overall_leagues
  before_action :find_user_fantasy_teams
  before_action :find_user_lineups
  before_action :find_deadlines
  before_action :find_user_likes
  before_action :sort_seasons

  def show; end

  private

  def find_seasons
    @seasons =
      Rails.cache.fetch('draft_players_show_seasons_v4', expires_in: 4.hours, race_condition_ttl: 10.seconds) do
        Season.in_progress.or(Season.coming)
          .joins(:league)
          .hashable_pluck(:id, :uuid, :start_at, :name, :updated_at, 'leagues.slug', 'leagues.sport_kind')
      end
  end

  def find_overall_leagues
    @overall_leagues =
      FantasyLeague
        .where(name: 'Overall', leagueable_type: 'Season', leagueable_id: @seasons.pluck(:id))
        .hashable_pluck(:fantasy_leagues_teams_count, :leagueable_id)
  end

  def find_user_fantasy_teams
    @user_fantasy_teams =
      if @seasons.any?
        FantasyTeam
          .where(user: Current.user, season_id: @seasons.pluck(:id))
          .hashable_pluck(:id, :uuid, :name, :completed, :season_id)
      else
        []
      end
  end

  def find_user_lineups
    @user_lineups =
      if @user_fantasy_teams.any?
        Lineup
          .joins(:week)
          .where(weeks: { status: Week::ACTIVE })
          .where(fantasy_team_id: @user_fantasy_teams.pluck(:id))
          .hashable_pluck(:points, :final_points, :fantasy_team_id)
      else
        []
      end
  end

  def find_deadlines
    @deadlines =
      if @seasons.any?
        Rails.cache.fetch(
          ['draft_players_show_deadlines_v1', @seasons.pluck(:updated_at).max],
          expires_in: 24.hours,
          race_condition_ttl: 10.seconds
        ) do
          Week
            .coming
            .where(season_id: @seasons.pluck(:id))
            .hashable_pluck(:deadline_at, :season_id)
        end
      else
        []
      end
  end

  def find_user_likes
    @likeables =
      Rails.cache.fetch(['draft_players_show_likes_v1', Current.user.updated_at]) do
        Current.user.likes.where(likeable_type: 'Season').hashable_pluck(:id, :likeable_id)
      end
  end

  def sort_seasons
    likeables = @likeables.pluck(:likeable_id)
    @seasons =
      @seasons
        .sort_by do |season|
          [
            likeables.include?(season[:id]) ? 0 : 1,
            week_deadline_priority(season[:id])
          ].compact
        end
  end

  def week_deadline_priority(season_id)
    week = @deadlines.find { |element| element[:season_id] == season_id }
    return unless week

    week[:deadline_at]
  end
end
