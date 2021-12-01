# frozen_string_literal: true

describe Seasons::PlayersController, type: :controller do
  describe 'GET#index' do
    let!(:season) { create :season, active: true }
    let!(:seasons_team) { create :seasons_team, season: season }

    before do
      create_list :teams_player, 2, seasons_team: seasons_team

      get :index, params: { season_id: season.id, locale: 'en' }
    end

    it 'returns status 200' do
      expect(response.status).to eq 200
    end

    %w[id price player team].each do |attr|
      it "and contains team #{attr}" do
        expect(response.body).to have_json_path("season_players/data/0/attributes/#{attr}")
      end
    end
  end
end
