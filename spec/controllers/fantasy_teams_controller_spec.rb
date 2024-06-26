# frozen_string_literal: true

describe FantasyTeamsController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'

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
        let!(:fantasy_leagues_team) { create :fantasy_leagues_team, pointable: fantasy_team }

        it 'renders show page' do
          get :show, params: { id: fantasy_team.uuid, locale: 'en' }

          expect(response).to render_template :show
        end

        context 'for maintenable season' do
          before { fantasy_leagues_team.fantasy_league.season.update!(maintenance: true) }

          it 'renders show page' do
            get :show, params: { id: fantasy_team.uuid, locale: 'en' }

            expect(response).to render_template :show
          end
        end

        context 'for finishing season' do
          before { fantasy_team.season.update!(status: Season::FINISHING) }

          it 'renders 404 page' do
            get :show, params: { id: fantasy_team.uuid, locale: 'en' }

            expect(response).to render_template 'shared/404'
          end
        end
      end
    end

    def do_request
      get :show, params: { id: 'unexisting', locale: 'en' }
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing season' do
        it 'does not create fantasy team', :aggregate_failures do
          expect { do_request }.not_to change(FantasyTeam, :count)
          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing active season' do
        let!(:season) { create :season, active: true }
        let!(:fantasy_league) { create :fantasy_league, season: season, leagueable: season, name: 'Overall' }
        let(:request) { post :create, params: { season_id: season.uuid, locale: 'en' } }

        context 'if fantasy team is already exist' do
          let!(:fantasy_team) { create :fantasy_team, user: @current_user, season: season }

          before do
            create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
          end

          it 'does not create fantasy team', :aggregate_failures do
            expect { request }.not_to change(FantasyTeam, :count)
            expect(response).to redirect_to draft_players_path
          end
        end

        context 'if fantasy team is not exist' do
          it 'creates fantasy team', :aggregate_failures do
            expect { request }.to change(@current_user.fantasy_teams, :count).by(1)
            expect(response).to redirect_to fantasy_team_transfers_path(FantasyTeam.last.uuid)
          end

          context 'if invite token is saved in cookies' do
            let!(:user) { create :user }
            let!(:user_fantasy_league) {
              create :fantasy_league, leagueable: user, season: season, invite_code: SecureRandom.hex
            }

            before do
              cookies[:fantasy_sports_invite_code] = {
                value: user_fantasy_league.invite_code,
                expires: 1.week.from_now
              }
            end

            it 'creates fantasy team and joins by saved invite code', :aggregate_failures do
              expect { request }.to(
                change(@current_user.fantasy_teams, :count).by(1)
                  .and(change(user_fantasy_league.fantasy_teams, :count).by(1))
              )
              expect(response).to redirect_to fantasy_team_transfers_path(FantasyTeam.last.uuid)
            end
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
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing fantasy team' do
        it 'does not update fantasy team', :aggregate_failures do
          expect { do_request }.not_to change(FantasyTeam, :count)
          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing fantasy team' do
        let!(:fantasy_league) { create :fantasy_league }
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        before do
          create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
        end

        context 'for season at maintenance' do
          before do
            fantasy_team.season.update!(maintenance: true)

            patch :update, params: {
              id: fantasy_team.uuid, locale: 'en', fantasy_team: { name: 'New name', budget_cents: 50_000 }
            }
          end

          it 'returns status 422', :aggregate_failures do
            expect(response).to have_http_status :unprocessable_entity
            expect(response.parsed_body).to eq({ 'errors' => ['League is on maintenance'] })
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
              allow(complete_service).to receive_messages(success?: false, errors: [])
            end

            it 'calls complete service', :aggregate_failures do
              request

              expect(FantasyTeams::CompleteService).to have_received(:call)
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

            it 'calls complete service', :aggregate_failures do
              request

              expect(FantasyTeams::CompleteService).to have_received(:call)
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
