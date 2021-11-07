# frozen_string_literal: true

describe Users::RegistrationsController, type: :controller do
  describe 'GET#new' do
    it 'renders new template' do
      get :new

      expect(response).to render_template :new
    end
  end

  describe 'POST#create' do
    context 'for invalid credentials' do
      it 'renders new template' do
        post :create, params: { user: { email: '', password: '1' } }

        expect(response).to render_template :new
      end
    end

    context 'for short password' do
      it 'renders new template' do
        post :create, params: { user: { email: 'user@gmail.com', password: '1' } }

        expect(response).to render_template :new
      end
    end

    context 'without password confirmation' do
      it 'renders new template' do
        post :create, params: { user: { email: 'user@gmail.com', password: '12345678' } }

        expect(response).to render_template :new
      end
    end

    context 'for existed user' do
      let(:user) { create :user }

      it 'renders new template' do
        post :create, params: { user: { email: user.email, password: '12345678', password_confirmation: '12345678' } }

        expect(response).to render_template :new
      end
    end

    context 'for valid data' do
      it 'redirects to dashboard path' do
        post :create, params: { user: { email: 'user@gmail.com', password: '12345678', password_confirmation: '12345678' } }

        expect(response).to redirect_to root_path
      end
    end
  end
end
