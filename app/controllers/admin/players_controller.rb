# frozen_string_literal: true

module Admin
  class PlayersController < AdminController
    include Deps[create_form: 'forms.players.create']

    before_action :find_sport_positions, only: %i[index new]
    before_action :find_players, only: %i[index]

    def index; end

    def new
      @player = Player.new
    end

    def create
      # commento: players.name, players.position_kind
      case create_form.call(params: player_params)
      in { errors: errors } then redirect_to new_admin_player_path(sport_kind: params[:sport_kind]), alert: errors
      else
        redirect_to(
          admin_players_path(sport_kind: params[:sport_kind]),
          notice: t('controllers.admin.players.create.success')
        )
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

    def player_params
      params
        .require(:player)
        .permit(:position_kind)
        .to_h
        .merge(name: { en: params[:player][:name_en], ru: params[:player][:name_ru] })
    end
  end
end
