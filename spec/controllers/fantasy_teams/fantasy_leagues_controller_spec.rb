# frozen_string_literal: true

describe FantasyTeams::FantasyLeaguesController, type: :controller do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

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
          get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing fantasy team of user' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        before do
          get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }
        end

        it 'returns status 200' do
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      get :index, params: { fantasy_team_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'GET#new' do
    let!(:fantasy_team) { create :fantasy_team }

    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      before { fantasy_team.update(user: @current_user) }

      it 'renders new template' do
        get :new, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

        expect(response).to render_template :new
      end
    end

    def do_request
      get :new, params: { fantasy_team_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'POST#create' do
    let!(:season) { create :season }
    let!(:fantasy_team) { create :fantasy_team }
    let!(:fantasy_league) { create :fantasy_league, leagueable: season, season: season }

    before do
      create :fantasy_leagues_team, fantasy_league: fantasy_league, pointable: fantasy_team
    end

    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

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
          post :create, params: { fantasy_team_id: fantasy_team.uuid, fantasy_league: { name: '' }, locale: 'en' }

          expect(response).to have_http_status :not_found
        end
      end

      context 'for user fantasy team' do
        before { fantasy_team.update(user: @current_user) }

        context 'for invalid params' do
          let(:request) {
            post :create, params: { fantasy_team_id: fantasy_team.uuid, fantasy_league: { name: '' }, locale: 'en' }
          }

          it 'does not create fantasy league' do
            expect { request }.not_to change(FantasyLeague, :count)
          end

          it 'redirects to new template' do
            request

            expect(response).to redirect_to new_fantasy_team_fantasy_league_en_path
          end
        end

        context 'for valid params' do
          let(:request) {
            post :create, params: { fantasy_team_id: fantasy_team.uuid, fantasy_league: { name: 'Name' }, locale: 'en' }
          }

          it 'creates fantasy league' do
            expect { request }.to change(@current_user.fantasy_leagues, :count).by(1)
          end

          it 'redirects to leagues list' do
            request

            expect(response).to redirect_to fantasy_team_fantasy_leagues_en_path
          end
        end
      end
    end

    def do_request
      post :create, params: { fantasy_team_id: 'unexisting', fantasy_league: { name: 'Name' }, locale: 'en' }
    end
  end
end
