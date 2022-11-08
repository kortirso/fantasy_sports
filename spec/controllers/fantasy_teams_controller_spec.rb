# frozen_string_literal: true

describe FantasyTeamsController do
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

      context 'for invalid request format' do
        it 'renders 404 page' do
          get :show, params: { id: 'unexisting', locale: 'en', format: :xml }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing not user fantasy team' do
        let!(:fantasy_team) { create :fantasy_team }

        it 'renders 404 page' do
          get :show, params: { id: fantasy_team.uuid, locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing user fantasy team' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        before do
          create :fantasy_leagues_team, pointable: fantasy_team
        end

        it 'renders show page' do
          get :show, params: { id: fantasy_team.uuid, locale: 'en' }

          expect(response).to render_template :show
        end
      end
    end

    def do_request
      get :show, params: { id: 'unexisting', locale: 'en' }
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing season' do
        it 'does not create fantasy team' do
          expect { do_request }.not_to change(FantasyTeam, :count)
        end

        it 'and renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing active season' do
        let!(:season) { create :season, active: true }
        let!(:fantasy_league) { create :fantasy_league, season: season, leagueable: season, name: 'Overall' }
        let(:request) { post :create, params: { season_id: season.id, locale: 'en' } }

        context 'if fantasy team is already exist' do
          let!(:fantasy_team) { create :fantasy_team, user: @current_user }

          before do
            create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
          end

          it 'does not create fantasy team' do
            expect { request }.not_to change(FantasyTeam, :count)
          end

          it 'and redirects to home page' do
            request

            expect(response).to redirect_to home_en_path
          end
        end

        context 'if fantasy team is not exist' do
          it 'creates fantasy team' do
            expect { request }.to change(@current_user.fantasy_teams, :count).by(1)
          end

          it 'and redirects to home page' do
            request

            expect(response).to redirect_to fantasy_team_transfers_en_path(FantasyTeam.last.uuid)
          end
        end
      end
    end

    def do_request
      post :create, params: { season_id: 'unexisting', locale: 'en' }
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

        it 'and renders 404 page' do
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

            patch :update, params: {
              id: fantasy_team.uuid, locale: 'en', fantasy_team: { name: 'New name', budget_cents: 50_000 }
            }
          end

          it 'returns status 422' do
            expect(response).to have_http_status :unprocessable_entity
          end

          it 'and returns error about maintenance' do
            expect(JSON.parse(response.body)).to eq({ 'errors' => ['League is on maintenance'] })
          end
        end

        context 'for standard league' do
          let(:complete_service) { double }

          before do
            allow(FantasyTeams::CompleteService).to receive(:call).and_return(complete_service)
          end

          context 'for invalid data' do
            let(:request) {
              patch :update, params: {
                id: fantasy_team.uuid, locale: 'en', fantasy_team: { name: '', budget_cents: 50_000 }
              }
            }

            before do
              allow(complete_service).to receive(:success?).and_return(false)
              allow(complete_service).to receive(:errors).and_return([])
            end

            it 'calls complete service' do
              request

              expect(FantasyTeams::CompleteService).to have_received(:call)
            end

            it 'and returns json unprocessable_entity status with errors' do
              request

              expect(response).to have_http_status :unprocessable_entity
            end
          end

          context 'for valid data' do
            let(:request) {
              patch :update, params: {
                id: fantasy_team.uuid, locale: 'en', fantasy_team: { name: 'New name', budget_cents: 50_000 }
              }
            }

            before do
              allow(complete_service).to receive(:success?).and_return(true)
            end

            it 'calls complete service' do
              request

              expect(FantasyTeams::CompleteService).to have_received(:call)
            end

            it 'and returns json ok status' do
              request

              expect(response).to have_http_status :ok
            end
          end
        end
      end
    end

    def do_request
      patch :update, params: { id: 'unexisting', locale: 'en' }
    end
  end
end
