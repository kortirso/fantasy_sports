# frozen_string_literal: true

describe Lineups::PlayersController do
  describe 'PATCH#update' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing lineup' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing lineup of another user' do
        let!(:lineup) { create :lineup }

        it 'returns json not_found status with errors' do
          patch :update, params: { lineup_id: lineup.uuid, locale: 'en', lineup_players: { data: [{}] } }

          expect(response).to have_http_status :not_found
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
            create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team

            fantasy_league.season.league.update(maintenance: true)

            patch :update, params: {
              lineup_id: lineup.uuid,
              locale: 'en',
              lineup_players: { data: [{ 'uuid' => lineups_player.uuid, 'change_order' => '0' }] }
            }
          end

          it 'returns status 422', :aggregate_failures do
            expect(response).to have_http_status :unprocessable_entity
            expect(response.parsed_body).to eq({ 'errors' => ['League is on maintenance'] })
          end
        end

        context 'for standard league' do
          let(:service_object) { double }

          before do
            allow(Lineups::Players::UpdateService).to receive(:call).and_return(service_object)
            allow(service_object).to receive_messages(success?: update_result, errors: ['Error'])

            patch :update, params: {
              lineup_id: lineup.uuid,
              locale: 'en',
              lineup_players: {
                data: [
                  {
                    'uuid' => lineups_player.uuid,
                    'change_order' => '0',
                    'status' => 'captain'
                  }
                ]
              }
            }
          end

          context 'for invalid data' do
            let(:update_result) { false }

            it 'returns status 422' do
              expect(response).to have_http_status :unprocessable_entity
            end
          end

          context 'for valid data' do
            let(:update_result) { true }

            it 'calls update service' do
              expect(Lineups::Players::UpdateService).to(
                have_received(:call).with(
                  lineup: lineup,
                  lineups_players_params: [
                    {
                      uuid: lineups_player.uuid,
                      change_order: 0,
                      status: 'captain'
                    }
                  ]
                )
              )
            end

            it 'returns status 200' do
              expect(response).to have_http_status :ok
            end
          end
        end
      end
    end

    def do_request
      patch :update, params: { lineup_id: 'unexisting', locale: 'en', lineup_players: { data: [{}] } }
    end
  end
end
