# frozen_string_literal: true

describe FantasyCupsController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'

    context 'for logged confirmed users' do
      sign_in_user

      context 'for not existing cup' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing cup' do
        let!(:cup) { create :fantasy_cup }

        context 'for not existing fantasy team' do
          it 'renders show template' do
            get :show, params: { id: cup.uuid, locale: 'en' }

            expect(response).to render_template 'shared/404'
          end
        end

        context 'for existing fantasy team' do
          let!(:fantasy_team) { create :fantasy_team, user: @current_user }
          let!(:fantasy_leagues_team) { create :fantasy_leagues_team, pointable: fantasy_team }
          let!(:lineup1) { create :lineup, fantasy_team: fantasy_team }
          let!(:lineup2) { create :lineup, fantasy_team: fantasy_team }

          before do
            cup.update!(fantasy_league: fantasy_leagues_team.fantasy_league)
            cups_round1 = create :fantasy_cups_round, fantasy_cup: cup, week: lineup1.week
            cups_round2 = create :fantasy_cups_round, fantasy_cup: cup, week: lineup2.week
            create :fantasy_cups_pair, home_lineup: lineup1, fantasy_cups_round: cups_round1
            create :fantasy_cups_pair, visitor_lineup: lineup2, fantasy_cups_round: cups_round2
          end

          it 'renders show template' do
            get :show, params: { id: cup.uuid, locale: 'en' }

            expect(response).to render_template :show
          end
        end
      end
    end

    def do_request
      get :show, params: { id: 'unexisting', locale: 'en' }
    end
  end
end
