# frozen_string_literal: true

describe FantasyTeams::TransfersController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing fantasy team' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing not user fantasy team' do
        let!(:fantasy_team) { create :fantasy_team }

        it 'renders 404 page' do
          get :show, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing user fantasy team' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        before do
          create :fantasy_leagues_team, pointable: fantasy_team
        end

        it 'renders index page' do
          get :show, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

          expect(response).to render_template :show
        end
      end
    end

    def do_request
      get :show, params: { fantasy_team_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing fantasy team' do
        it 'does not update fantasy team' do
          expect { do_request }.not_to change(FantasyTeam, :count)
        end

        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing fantasy team' do
        let!(:fantasy_league) { create :fantasy_league }
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        before do
          create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
        end

        context 'for league at maintenance' do
          before do
            fantasy_league.season.league.update(maintenance: true)

            patch :update, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }
          end

          it 'returns status 422', :aggregate_failures do
            expect(response).to have_http_status :unprocessable_entity
            expect(response.parsed_body).to eq({ 'errors' => ['League is on maintenance'] })
          end
        end

        context 'for standard league' do
          let(:perform_service) { double }

          before do
            allow(FantasyTeams::Transfers::PerformService).to receive(:call).and_return(perform_service)
          end

          context 'for invalid data' do
            let(:request) {
              patch :update, params: {
                fantasy_team_id: fantasy_team.uuid,
                locale: 'en',
                fantasy_team: { teams_players_uuids: [], only_validate: true }
              }
            }

            before do
              allow(perform_service).to receive_messages(success?: false, errors: [])
            end

            it 'calls complete service', :aggregate_failures do
              request

              expect(FantasyTeams::Transfers::PerformService).to have_received(:call)
              expect(response).to have_http_status :unprocessable_entity
            end
          end

          context 'for valid data' do
            let(:request) {
              patch :update, params: {
                fantasy_team_id: fantasy_team.uuid,
                locale: 'en',
                fantasy_team: { teams_players_uuids: [], only_validate: true }
              }
            }

            before do
              allow(perform_service).to receive_messages(
                success?: true,
                result: I18n.t('services.fantasy_teams.transfers.perform.success')
              )
            end

            it 'calls complete service', :aggregate_failures do
              request

              expect(FantasyTeams::Transfers::PerformService).to have_received(:call)
              expect(response).to have_http_status :ok
            end
          end
        end
      end
    end

    def do_request
      patch :update, params: { fantasy_team_id: 'unexisting', locale: 'en' }
    end
  end
end
