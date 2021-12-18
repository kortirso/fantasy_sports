# frozen_string_literal: true

describe Lineups::PlayersController, type: :controller do
  describe 'GET#show' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :show, params: { lineup_id: 'unexisted', locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not existed lineup' do
        it 'returns json not_found status with errors' do
          get :show, params: { lineup_id: 'unexisted', locale: 'en' }

          expect(response.status).to eq 404
        end
      end

      context 'for existed lineupof another user' do
        let!(:lineup) { create :lineup }

        it 'returns json not_found status with errors' do
          get :show, params: { lineup_id: lineup.id, locale: 'en' }

          expect(response.status).to eq 404
        end
      end

      context 'for existed lineup of user' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }
        let!(:lineup) { create :lineup, fantasy_team: fantasy_team }

        context 'without additional fields' do
          before do
            create :lineups_player, lineup: lineup

            get :show, params: { lineup_id: lineup.id, locale: 'en' }
          end

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          %w[id active change_order points player team].each do |attr|
            it "and contains lineups player #{attr}" do
              expect(response.body).to have_json_path("lineup_players/data/0/attributes/#{attr}")
            end
          end

          it 'and does not contain lineups player team opposite_team_ids' do
            expect(response.body).not_to have_json_path('lineup_players/data/0/attributes/team/opposite_team_ids')
          end
        end

        context 'with additional fields' do
          before do
            create :lineups_player, lineup: lineup

            get :show, params: { lineup_id: lineup.id, locale: 'en', fields: 'opposite_teams' }
          end

          it 'returns status 200' do
            expect(response.status).to eq 200
          end

          %w[id active change_order points player team].each do |attr|
            it "and contains lineups player #{attr}" do
              expect(response.body).to have_json_path("lineup_players/data/0/attributes/#{attr}")
            end
          end

          it 'and contains lineups player team opposite_team_ids' do
            expect(response.body).to have_json_path('lineup_players/data/0/attributes/team/opposite_team_ids')
          end
        end
      end
    end
  end
end
