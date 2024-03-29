# frozen_string_literal: true

describe TeamsController do
  describe 'GET#index' do
    let!(:season) { create :season, active: true }

    before do
      create_list :seasons_team, 2, season: season

      get :index, params: { season_uuid: season.uuid, locale: 'en' }
    end

    it 'returns status 200', :aggregate_failures do
      expect(response).to have_http_status :ok
      %w[uuid name].each do |attr|
        expect(response.body).to have_json_path("teams/data/0/attributes/#{attr}")
      end
    end
  end
end
