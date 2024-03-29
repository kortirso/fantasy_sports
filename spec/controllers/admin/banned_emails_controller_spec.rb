# frozen_string_literal: true

describe Admin::BannedEmailsController do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'
    it_behaves_like 'required admin'

    context 'for authorized user' do
      sign_in_admin

      it 'renders index page' do
        do_request

        expect(response).to render_template :index
      end
    end

    def do_request
      get :index, params: { locale: 'en' }
    end
  end

  describe 'GET#new' do
    it_behaves_like 'required auth'
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
    it_behaves_like 'required admin'

    context 'for admin' do
      let!(:user) { create :user }

      sign_in_admin

      context 'for invalid params' do
        let(:request) { post :create, params: { banned_email: { value: '', reason: '' }, locale: 'en' } }

        it 'does not create banned_email', :aggregate_failures do
          expect { request }.not_to change(BannedEmail, :count)
          expect(response).to redirect_to new_admin_banned_email_path
        end
      end

      context 'for valid params' do
        let(:request) {
          post :create, params: { banned_email: { value: user.email, reason: 'Spam' }, locale: 'en' }
        }

        it 'creates banned_email', :aggregate_failures do
          expect { request }.to change(BannedEmail, :count).by(1)
          expect(user.reload.banned_at).not_to be_nil
          expect(response).to redirect_to admin_banned_emails_path
        end
      end
    end

    def do_request
      post :create, params: { banned_email: { value: '', reason: '' }, locale: 'en' }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'
    it_behaves_like 'required admin'

    context 'for admin' do
      let!(:user) { create :user, banned_at: 1.week.ago }
      let!(:banned_email) { create :banned_email, value: user.email }

      sign_in_admin

      context 'for not existing banned email' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing banned email' do
        let(:request) { delete :destroy, params: { id: banned_email.id, locale: 'en' } }

        it 'destroys banned_email', :aggregate_failures do
          expect { request }.to change(BannedEmail, :count).by(-1)
          expect(user.reload.banned_at).to be_nil
          expect(response).to redirect_to admin_banned_emails_path
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting', locale: 'en' }
    end
  end
end
