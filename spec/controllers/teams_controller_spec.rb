# frozen_string_literal: true

describe TeamsController, type: :controller do
  describe 'GET#index' do
    let!(:leagues_season) { create :leagues_season, active: true }

    before do
      create_list :leagues_seasons_team, 2, leagues_season: leagues_season

      get :index, params: { league_id: leagues_season.league_id }
    end

    it 'returns status 200' do
      expect(response.status).to eq 200
    end

    %w[id name].each do |attr|
      it "and contains team #{attr}" do
        expect(response.body).to have_json_path("teams/data/0/attributes/#{attr}")
      end
    end
  end
end
