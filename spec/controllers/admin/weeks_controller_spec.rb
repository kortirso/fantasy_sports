# frozen_string_literal: true

describe Admin::WeeksController do
  let!(:season) { create :season }
  let!(:week) { create :week, season: season, deadline_at: DateTime.new(2024, 1, 1, 12, 0, 0) }

  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing season' do
        it 'renders index template' do
          get :index, params: { season_id: season.id, locale: 'en' }

          expect(response).to render_template :index
        end
      end
    end

    def do_request
      get :index, params: { season_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'GET#edit' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for not existing season' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing week' do
        it 'renders edit template' do
          get :edit, params: { id: week.id, locale: 'en' }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { id: 'unexisting', locale: 'en' }
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for not existing week' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for valid params with empty deadline' do
        it 'does not update week', :aggregate_failures do
          patch :update, params: { id: week.id, week: { deadline_at: '' }, locale: 'en' }

          expect(week.reload.deadline_at.strftime('%Y-%m-%d %H:%M')).to eq '2024-01-01 12:00'
          expect(response).to redirect_to admin_weeks_path(season_id: season.id)
        end
      end

      context 'for valid params with deadline' do
        it 'updates week', :aggregate_failures do
          patch :update, params: { id: week.id, week: { deadline_at: '2024-01-31 12:55' }, locale: 'en' }

          expect(week.reload.deadline_at.strftime('%Y-%m-%d %H:%M')).to eq '2024-01-31 12:55'
          expect(response).to redirect_to admin_weeks_path(season_id: season.id)
        end
      end
    end

    def do_request
      patch :update, params: { id: 'unexisting', week: { deadline_at: '' }, locale: 'en' }
    end
  end
end
