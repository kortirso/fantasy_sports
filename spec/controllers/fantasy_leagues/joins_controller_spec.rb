# frozen_string_literal: true

describe FantasyLeagues::JoinsController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      before do
        allow(FantasyLeagues::JoinService).to receive(:call)
      end

      context 'for not existing fantasy league' do
        before { do_request }

        it 'does not call join service', :aggregate_failures do
          expect(FantasyLeagues::JoinService).not_to have_received(:call)
          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing fantasy league' do
        let!(:user) { create :user }

        context 'for unexisting invite code' do
          let!(:fantasy_league) { create :fantasy_league, leagueable: user, invite_code: nil }

          before { get :index, params: { fantasy_league_id: fantasy_league.uuid, invite_code: '1234', locale: 'en' } }

          it 'does not call join service', :aggregate_failures do
            expect(FantasyLeagues::JoinService).not_to have_received(:call)
            expect(response).to redirect_to home_path
          end
        end

        context 'for invalid invite code' do
          let!(:fantasy_league) { create :fantasy_league, leagueable: user, invite_code: SecureRandom.hex }

          before { get :index, params: { fantasy_league_id: fantasy_league.uuid, invite_code: '1234', locale: 'en' } }

          it 'does not call join service', :aggregate_failures do
            expect(FantasyLeagues::JoinService).not_to have_received(:call)
            expect(response).to redirect_to home_path
          end
        end

        context 'for valid invite code' do
          let!(:season) { create :season }
          let!(:fantasy_league) {
            create :fantasy_league, leagueable: user, season: season, invite_code: SecureRandom.hex
          }
          let!(:another_fantasy_league) { create :fantasy_league, leagueable: season, season: season }

          let(:request) do
            get :index, params: {
              fantasy_league_id: fantasy_league.uuid, invite_code: fantasy_league.invite_code, locale: 'en'
            }
          end

          context 'for unexisting fantasy team of user' do
            before { request }

            it 'does not call join service', :aggregate_failures do
              expect(FantasyLeagues::JoinService).not_to have_received(:call)
              expect(response).to redirect_to home_path
            end
          end

          context 'for existing fantasy team of user' do
            let!(:fantasy_team) { create :fantasy_team, user: @current_user, season: season }

            context 'for first joining to league' do
              before do
                create :fantasy_leagues_team, fantasy_league: another_fantasy_league, pointable: fantasy_team

                request
              end

              it 'calls join service', :aggregate_failures do
                expect(FantasyLeagues::JoinService).to have_received(:call)
                expect(response).to redirect_to fantasy_team_fantasy_leagues_path(fantasy_team.uuid)
              end
            end

            context 'for second joining to league' do
              before do
                create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team

                request
              end

              it 'does not call join service', :aggregate_failures do
                expect(FantasyLeagues::JoinService).not_to have_received(:call)
                expect(response).to redirect_to home_path
              end
            end
          end
        end
      end
    end

    def do_request
      get :index, params: { fantasy_league_id: 'unexisting', invite_code: '', locale: 'en' }
    end
  end
end
