# frozen_string_literal: true

describe Users::SessionsController, type: :controller do
  describe 'GET#new' do
    it 'renders new template' do
      get :new

      expect(response).to render_template :new
    end
  end

  describe 'POST#create' do
    context 'for unexisted user' do
      it 'renders new template' do
        post :create, params: { user: { email: 'unexisted@gmail.com', password: '1' } }

        expect(response).to render_template :new
      end
    end

    context 'for exissted user' do
      let(:user) { create :user }

      context 'for invalid password' do
        it 'renders new template' do
          post :create, params: { user: { email: user.email, password: 'invalid_password' } }

          expect(response).to render_template :new
        end
      end

      context 'for empty password' do
        it 'renders new template' do
          post :create, params: { user: { email: user.email, password: '' } }

          expect(response).to render_template :new
        end
      end

      context 'for valid password' do
        it 'redirects to dashboard path' do
          post :create, params: { user: { email: user.email, password: user.password } }

          expect(response).to redirect_to root_path
        end
      end
    end
  end

  describe 'GET#destroy' do
    it 'redirects to root path' do
      get :destroy

      expect(response).to redirect_to root_path
    end
  end
end
