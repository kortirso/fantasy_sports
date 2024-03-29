# frozen_string_literal: true

describe Admin::CupsController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for authorized user' do
        before { create :season }

        it 'renders index page' do
          do_request

          expect(response).to render_template :index
        end
      end
    end

    def do_request
      get :index, params: { locale: 'en' }
    end
  end

  describe 'GET#new' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      it 'renders new page' do
        do_request

        expect(response).to render_template :new
      end
    end

    def do_request
      get :new, params: { locale: 'en' }
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      let!(:league) { create :league }

      sign_in_admin

      context 'for invalid params' do
        let(:request) { post :create, params: { cup: { name_en: '', name_ru: '' }, locale: 'en' } }

        it 'does not create cup', :aggregate_failures do
          expect { request }.not_to change(Cup, :count)
          expect(response).to redirect_to new_admin_cup_path
        end
      end

      context 'for invalid league' do
        it 'does not create cup', :aggregate_failures do
          expect { do_request }.not_to change(Cup, :count)
          expect(response).to redirect_to new_admin_cup_path
        end
      end

      context 'for valid params' do
        let(:request) {
          post :create, params: { cup: { name_en: 'En', name_ru: 'ru', league_id: league.id }, locale: 'en' }
        }

        it 'creates cup', :aggregate_failures do
          expect { request }.to change(league.cups, :count).by(1)
          expect(response).to redirect_to admin_cups_path
        end
      end
    end

    def do_request
      post :create, params: { cup: { name_en: 'En', name_ru: 'Ru', league_id: 'unexisting' }, locale: 'en' }
    end
  end
end
