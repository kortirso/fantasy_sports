# frozen_string_literal: true

describe Seasons::PlayersController, type: :controller do
  describe 'GET#index' do
    context 'for not existed season' do
      before do
        get :index, params: { season_id: 'unexisted', locale: 'en' }
      end

      it 'returns status 404' do
        expect(response.status).to eq 404
      end
    end

    context 'for existed season' do
      let!(:season) { create :season, active: true }
      let!(:seasons_team) { create :seasons_team, season: season }

      before do
        create_list :teams_player, 2, seasons_team: seasons_team
      end

      context 'without additional params' do
        before do
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

        %w[points statistic].each do |attr|
          it "and does not contain teams player #{attr}" do
            expect(response.body).not_to have_json_path("season_players/data/0/attributes/player/#{attr}")
          end
        end
      end

      context 'with additional params' do
        before do
          get :index, params: { season_id: season.id, locale: 'en', fields: 'season_statistic' }
        end

        it 'returns status 200' do
          expect(response.status).to eq 200
        end

        %w[id price player team].each do |attr|
          it "and contains team #{attr}" do
            expect(response.body).to have_json_path("season_players/data/0/attributes/#{attr}")
          end
        end

        %w[points statistic].each do |attr|
          it "and contains teams player #{attr}" do
            expect(response.body).to have_json_path("season_players/data/0/attributes/player/#{attr}")
          end
        end
      end
    end
  end
end
