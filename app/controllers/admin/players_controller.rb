# frozen_string_literal: true

module Admin
  class PlayersController < Admin::BaseController
    include Deps[
      create_form: 'forms.players.create',
      update_form: 'forms.players.update',
    ]

    before_action :find_sport_positions, only: %i[index new edit update]
    before_action :find_players, only: %i[index edit update]
    before_action :find_player, only: %i[edit update]

    def index; end

    def new
      @player = Player.new
    end

    def edit; end

    def create
      # commento: players.first_name, players.last_name, players.nickname, players.position_kind
      case create_form.call(params: player_params)
      in { errors: errors } then redirect_to new_admin_player_path(sport_kind: params[:sport_kind]), alert: errors
      else redirect_to admin_players_path(sport_kind: params[:sport_kind])
      end
    end

    def update
      # commento: players.first_name, players.last_name, players.nickname, players.position_kind
      case update_form.call(player: @player, params: player_params)
      in { errors: errors }
        redirect_to edit_admin_player_path(id: @player.id, sport_kind: params[:sport_kind]), alert: errors
      else redirect_to admin_players_path(sport_kind: params[:sport_kind])
      end
    end

    private

    def find_sport_positions
      return unless params[:sport_kind]

      @sport_positions = Sports::Position.where(sport: params[:sport_kind]).pluck(:title, :name).to_h
    end

    def find_players
      return unless params[:sport_kind]

      @players = Player.where(position_kind: @sport_positions.keys)
    end

    def find_player
      @player = @players.find(params[:id])
    end

    # rubocop: disable Metrics/AbcSize
    def player_params
      params
        .require(:player)
        .permit(:position_kind)
        .to_h
        .merge(
          first_name: { en: params[:player][:first_name_en], ru: params[:player][:first_name_ru] },
          last_name: { en: params[:player][:last_name_en], ru: params[:player][:last_name_ru] },
          nickname: { en: params[:player][:nickname_en], ru: params[:player][:nickname_ru] }
        )
    end
    # rubocop: enable Metrics/AbcSize
  end
end
