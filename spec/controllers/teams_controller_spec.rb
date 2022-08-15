# frozen_string_literal: true

describe TeamsController, type: :controller do
  describe 'GET#index' do
    let!(:season) { create :season, active: true }

    before do
      create_list :seasons_team, 2, season: season

      get :index, params: { season_id: season.id, locale: 'en' }
    end

    it 'returns status 200' do
      expect(response).to have_http_status :ok
    end

    %w[id name].each do |attr|
      it "and contains team #{attr}" do
        expect(response.body).to have_json_path("teams/data/0/attributes/#{attr}")
      end
    end
  end
end
