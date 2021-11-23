# frozen_string_literal: true

describe Teams::PlayersController, type: :controller do
  describe 'GET#index' do
    let!(:leagues_season) { create :leagues_season, active: true }
    let!(:leagues_seasons_team) { create :leagues_seasons_team, leagues_season: leagues_season }

    before do
      create_list :teams_player, 2, leagues_seasons_team: leagues_seasons_team

      get :index, params: { season_id: leagues_season.id }
    end

    it 'returns status 200' do
      expect(response.status).to eq 200
    end

    %w[id price player team].each do |attr|
      it "and contains team #{attr}" do
        expect(response.body).to have_json_path("teams_players/data/0/attributes/#{attr}")
      end
    end
  end
end
