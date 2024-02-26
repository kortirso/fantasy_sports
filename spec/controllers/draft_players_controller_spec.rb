# frozen_string_literal: true

describe DraftPlayersController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      before do
        season = create :season, active: true
        create :fantasy_league, season: season, leagueable: season, name: 'Overall'
        fantasy_team = create :fantasy_team, season: season, user: @current_user
        week = create :week, status: Week::ACTIVE
        create :lineup, week: week, fantasy_team: fantasy_team
      end

      it 'renders show template' do
        do_request

        expect(response).to render_template :show
      end
    end

    def do_request
      get :show, params: { locale: 'en' }
    end
  end
end
