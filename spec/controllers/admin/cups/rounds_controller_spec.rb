# frozen_string_literal: true

describe Admin::Cups::RoundsController do
  let!(:cup) { create :cup }

  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for authorized user' do
        before { create :cups_round, cup: cup }

        it 'renders index page' do
          do_request

          expect(response).to render_template :index
        end
      end
    end

    def do_request
      get :index, params: { cup_id: cup.id, locale: 'en' }
    end
  end

  describe 'GET#new' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for unexisting cup' do
        it 'render not found page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing cup' do
        it 'renders new page' do
          get :new, params: { cup_id: cup.id, locale: 'en' }

          expect(response).to render_template :new
        end
      end
    end

    def do_request
      get :new, params: { cup_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for unexisting cup' do
        it 'does not create cups round', :aggregate_failures do
          expect { do_request }.not_to change(Cups::Round, :count)
          expect(response).to render_template 'shared/404'
        end
      end

      context 'for invalid params' do
        let(:request) { post :create, params: { cup_id: cup.id, cups_round: { name: '', position: '1' } } }

        it 'does not create cups round', :aggregate_failures do
          expect { request }.not_to change(Cups::Round, :count)
          expect(response).to redirect_to new_admin_cup_round_path(cup_id: cup.id)
        end
      end

      context 'for valid params' do
        let(:request) { post :create, params: { cup_id: cup.id, cups_round: { name: '1/8', position: '1' } } }

        it 'creates cups round', :aggregate_failures do
          expect { request }.to change(cup.cups_rounds, :count).by(1)
          expect(response).to redirect_to admin_cup_rounds_path(cup_id: cup.id)
        end
      end
    end

    def do_request
      post :create, params: { cup_id: 'unexisting', cups_round: { name: '1/8', position: '1' } }
    end
  end

  describe 'GET#refresh_oraculs_points' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      before { allow(Oraculs::Lineups::Points::UpdateJob).to receive(:perform_later) }

      context 'for unexisting cups round' do
        it 'render not found page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing cups round' do
        let!(:cups_round) { create :cups_round, cup: cup }

        it 'runs background job', :aggregate_failures do
          get :refresh_oraculs_points, params: { cups_round_id: cups_round.id, locale: 'en' }

          expect(Oraculs::Lineups::Points::UpdateJob).to(
            have_received(:perform_later).with(periodable_id: cups_round.id, periodable_type: 'Cups::Round')
          )
          expect(response).to redirect_to admin_cup_rounds_path(cup_id: cup.id)
        end
      end
    end

    def do_request
      get :refresh_oraculs_points, params: { cups_round_id: 'unexisting', locale: 'en' }
    end
  end
end
