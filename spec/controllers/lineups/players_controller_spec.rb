# frozen_string_literal: true

describe Lineups::PlayersController, type: :controller do
  describe 'GET#show' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :show, params: { lineup_id: 'unexisting', locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not existing lineup' do
        it 'returns json not_found status with errors' do
          get :show, params: { lineup_id: 'unexisting', locale: 'en' }

          expect(response.status).to eq 404
        end
      end

      context 'for existing lineup of another user' do
        let!(:lineup) { create :lineup }

        it 'returns json not_found status with errors' do
          get :show, params: { lineup_id: lineup.id, locale: 'en' }

          expect(response.status).to eq 404
        end
      end

      context 'for existing lineup of user' do
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

          %w[id active change_order points player team teams_player_id].each do |attr|
            it "and contains lineups player #{attr}" do
              expect(response.body).to have_json_path("lineup_players/data/0/attributes/#{attr}")
            end
          end
        end
      end
    end
  end

  describe 'PATCH#update' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        patch :update, params: { lineup_id: 'unexisting', locale: 'en', lineup_players: { data: [{}] } }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not existing lineup' do
        it 'returns json not_found status with errors' do
          patch :update, params: { lineup_id: 'unexisting', locale: 'en', lineup_players: { data: [{}] } }

          expect(response.status).to eq 404
        end
      end

      context 'for existing lineup of another user' do
        let!(:lineup) { create :lineup }

        it 'returns json not_found status with errors' do
          patch :update, params: { lineup_id: lineup.id, locale: 'en', lineup_players: { data: [{}] } }

          expect(response.status).to eq 404
        end
      end

      context 'for existing lineup of user' do
        let!(:fantasy_league) { create :fantasy_league }
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }
        let!(:week) { create :week, season: fantasy_league.season }
        let!(:lineup) { create :lineup, fantasy_team: fantasy_team, week: week }
        let!(:lineups_player) { create :lineups_player, lineup: lineup }

        context 'for league at maintenance' do
          before do
            create :fantasy_leagues_team, fantasy_league: fantasy_league, fantasy_team: fantasy_team

            fantasy_league.season.league.update(maintenance: true)

            patch :update, params: {
              lineup_id:      lineup.id,
              locale:         'en',
              lineup_players: { data: [{ 'id' => lineups_player.id, 'active' => true, 'change_order' => 0 }] }
            }
          end

          it 'returns status 422' do
            expect(response.status).to eq 422
          end

          it 'and returns error about maintenance' do
            expect(JSON.parse(response.body)).to eq({ 'errors' => ['League is on maintenance'] })
          end
        end

        context 'for standard league' do
          let(:service_object) { double }

          before do
            allow(::Lineups::Players::UpdateService).to receive(:call).and_return(service_object)
            allow(service_object).to receive(:success?).and_return(update_result)
            allow(service_object).to receive(:errors).and_return(['Error'])

            patch :update, params: {
              lineup_id:      lineup.id,
              locale:         'en',
              lineup_players: { data: [{ 'id' => lineups_player.id, 'active' => true, 'change_order' => 0 }] }
            }
          end

          context 'for invalid data' do
            let(:update_result) { false }

            it 'returns status 422' do
              expect(response.status).to eq 422
            end
          end

          context 'for valid data' do
            let(:update_result) { true }

            it 'returns status 200' do
              expect(response.status).to eq 200
            end
          end
        end
      end
    end
  end
end
