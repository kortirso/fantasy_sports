# frozen_string_literal: true

describe Admin::Cups::PairsController do
  let!(:cup) { create :cup }
  let!(:cups_round) { create :cups_round, cup: cup }

  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for authorized user' do
        before { create :cups_pair, cups_round: cups_round }

        it 'renders index page' do
          do_request

          expect(response).to render_template :index
        end
      end
    end

    def do_request
      get :index, params: { cups_round_id: cups_round.id, locale: 'en' }
    end
  end

  describe 'GET#new' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for unexisting cups round' do
        it 'render not found page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing cups round' do
        it 'renders new page' do
          get :new, params: { cups_round_id: cups_round.id, locale: 'en' }

          expect(response).to render_template :new
        end
      end
    end

    def do_request
      get :new, params: { cups_round_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'GET#edit' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for unexisting cups round' do
        it 'render not found page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for unexisting cups pair' do
        it 'render not found page' do
          get :edit, params: { cups_round_id: cups_round.id, id: 'unexisting', locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing cups round and pair' do
        let!(:cups_pair) { create :cups_pair, cups_round: cups_round }

        it 'renders edit page' do
          get :edit, params: { cups_round_id: cups_round.id, id: cups_pair, locale: 'en' }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { cups_round_id: 'unexisting', id: 'unexisting', locale: 'en' }
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for unexisting cups round' do
        it 'does not create cups pair', :aggregate_failures do
          expect { do_request }.not_to change(Cups::Pair, :count)
          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing cups round' do
        let(:request) {
          post :create, params: {
            cups_round_id: cups_round.id, cups_pair: { home_name_en: 'Home', visitor_name_en: 'Visitor' }
          }
        }

        it 'creates cups pair', :aggregate_failures do
          expect { request }.to change(cups_round.cups_pairs, :count).by(1)
          expect(response).to redirect_to admin_cups_round_pairs_path(cups_round_id: cups_round.id)
        end
      end
    end

    def do_request
      post :create, params: { cups_round_id: 'unexisting', cups_pair: { home_name: 'Home', visitor_name: 'Visitor' } }
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for admin' do
      sign_in_admin

      context 'for unexisting cups round' do
        it 'redirects to not found page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for unexisting cups pair' do
        it 'redirects to not found page' do
          patch :update, params: { cups_round_id: cups_round.id, id: 'unexisting', cups_pair: { home_name_en: 'Home' } }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing cups round' do
        let!(:cups_pair) { create :cups_pair, cups_round: cups_round, home_name: 'Old home', points: [3, 1] }
        let(:request) {
          patch :update, params: {
            cups_round_id: cups_round.id, id: cups_pair.id, cups_pair: { home_name_en: 'Home', points: '2-1' }
          }
        }

        it 'updates cups pair', :aggregate_failures do
          request

          expect(cups_pair.reload.home_name['en']).to eq 'Home'
          expect(cups_pair.points).to eq([2, 1])
          expect(response).to redirect_to admin_cups_round_pairs_path(cups_round_id: cups_round.id)
        end

        context 'for best of elimination' do
          let(:request) {
            patch :update, params: {
              cups_round_id: cups_round.id, id: cups_pair.id, cups_pair: {
                home_name_en: 'Home',
                points: '2-1',
                elimination_kind: Cups::Pair::BEST_OF,
                required_wins: '2'
              }
            }
          }

          it 'updates cups pair', :aggregate_failures do
            request

            expect(cups_pair.reload.home_name['en']).to eq 'Home'
            expect(cups_pair.points).to eq([2, 1])
            expect(cups_pair.required_wins).to eq 2
            expect(response).to redirect_to admin_cups_round_pairs_path(cups_round_id: cups_round.id)
          end
        end
      end
    end

    def do_request
      patch :update, params: {
        cups_round_id: 'unexisting', id: 'unexisting', cups_pair: { home_name_en: 'Home', visitor_name_en: 'Visitor' }
      }
    end
  end
end
