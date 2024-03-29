# frozen_string_literal: true

describe Api::Frontend::FantasyTeams::FantasyLeaguesController do
  describe 'POST#create' do
    let!(:season) { create :season }
    let!(:fantasy_team) { create :fantasy_team }
    let!(:fantasy_league) { create :fantasy_league, leagueable: season, season: season }

    before do
      create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
    end

    it_behaves_like 'required auth'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      context 'for not existing fantasy team' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing fantasy team of another user' do
        let!(:fantasy_team) { create :fantasy_team }

        it 'returns json not_found status with errors' do
          post :create, params: { fantasy_team_id: fantasy_team.uuid, fantasy_league: { name: '' } }, format: :json

          expect(response).to have_http_status :not_found
        end
      end

      context 'for user fantasy team' do
        before { fantasy_team.update(user: @current_user) }

        context 'for invalid params' do
          let(:request) {
            post :create, params: { fantasy_team_id: fantasy_team.uuid, fantasy_league: { name: '' } }, format: :json
          }

          it 'does not create fantasy league' do
            expect { request }.not_to change(FantasyLeague, :count)
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: {
              fantasy_team_id: fantasy_team.uuid, fantasy_league: { name: 'Name' }
            }, format: :json
          }

          it 'creates fantasy league' do
            expect { request }.to change(@current_user.fantasy_leagues, :count).by(1)
          end
        end
      end
    end

    def do_request
      post :create, params: { fantasy_team_id: 'unexisting', fantasy_league: { name: 'Name' } }, format: :json
    end
  end
end
