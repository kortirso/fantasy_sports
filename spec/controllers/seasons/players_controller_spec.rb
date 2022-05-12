# frozen_string_literal: true

describe Seasons::PlayersController, type: :controller do
  describe 'GET#index' do
    context 'for not existing season' do
      before do
        get :index, params: { season_id: 'unexisting', locale: 'en' }
      end

      it 'returns status 404' do
        expect(response.status).to eq 404
      end
    end

    context 'for existing season' do
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
        it "response contains team #{attr}" do
          expect(response.body).to have_json_path("season_players/data/0/attributes/#{attr}")
        end
      end

      %w[points statistic].each do |attr|
        it "response contains teams player #{attr}" do
          expect(response.body).to have_json_path("season_players/data/0/attributes/player/#{attr}")
        end
      end
    end
  end

  describe 'GET#show' do
    context 'for not existing season' do
      before do
        get :show, params: { season_id: 'unexisting', id: 'unexisting', locale: 'en' }
      end

      it 'returns status 404' do
        expect(response.status).to eq 404
      end
    end

    context 'for existing season' do
      let!(:season) { create :season, active: true }
      let!(:seasons_team) { create :seasons_team, season: season }
      let!(:teams_player) { create :teams_player, seasons_team: seasons_team }

      before do
        get :show, params: { season_id: season.id, id: teams_player.id, locale: 'en' }
      end

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w[id price player team].each do |attr|
        it "response contains team #{attr}" do
          expect(response.body).to have_json_path("season_player/data/attributes/#{attr}")
        end
      end

      %w[points statistic].each do |attr|
        it "response contains teams player #{attr}" do
          expect(response.body).to have_json_path("season_player/data/attributes/player/#{attr}")
        end
      end
    end
  end
end
