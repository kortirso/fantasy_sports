# frozen_string_literal: true

describe Api::Frontend::FantasyTeamsController do
  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      let!(:fantasy_team) { create :fantasy_team }
      let(:request) { delete :destroy, params: { id: fantasy_team.uuid } }

      sign_in_user

      context 'for team of another user' do
        it 'does not destroy fantasy team', :aggregate_failures do
          expect { request }.not_to change(FantasyTeam, :count)
          expect(response).to have_http_status :ok
          expect(response.parsed_body.dig('errors', 0)).to eq 'Fantasy team is not found'
        end
      end

      context 'for valid params' do
        before { fantasy_team.update!(user: @current_user) }

        it 'destroys fantasy team', :aggregate_failures do
          expect { request }.to change(@current_user.fantasy_teams, :count).by(-1)
          expect(response).to have_http_status :ok
          expect(response.parsed_body['errors']).to be_nil
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end
