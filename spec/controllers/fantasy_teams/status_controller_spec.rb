# frozen_string_literal: true

describe FantasyTeams::StatusController do
  describe 'GET#index' do
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

      context 'for existing user fantasy team' do
        let!(:another_user) { create :user }
        let!(:season) { create :season }
        let!(:week) { create :week }
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }
        let!(:fantasy_league) { create :fantasy_league, leagueable: season, season: season }

        before do
          create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team

          create :lineup, fantasy_team: fantasy_team, week: week
        end

        context 'for not existing active week' do
          it 'renders index page' do
            get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

            expect(response).to render_template :index
          end
        end

        context 'for existing active week' do
          before { week.update!(status: Week::ACTIVE) }

          it 'renders index page' do
            get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

            expect(response).to render_template :index
          end

          context 'for not user fantasy team' do
            before { fantasy_team.update!(user: another_user) }

            it 'renders index page' do
              get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

              expect(response).to render_template :index
            end
          end

          context 'with week param' do
            before { week.update!(status: Week::FINISHED) }

            it 'renders index page' do
              get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en', week: week.position }

              expect(response).to render_template :index
            end

            context 'for not user fantasy team' do
              before { fantasy_team.update!(user: another_user) }

              it 'renders index page' do
                get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en', week: week.position }

                expect(response).to render_template :index
              end
            end
          end
        end
      end
    end

    def do_request
      get :index, params: { fantasy_team_id: 'unexisting', locale: 'en' }
    end
  end
end
