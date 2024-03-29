# frozen_string_literal: true

describe ProfilesController do
  describe 'GET#show' do
    it_behaves_like 'required auth'
    it_behaves_like 'required available email'

    context 'for logged users' do
      sign_in_user

      it 'renders show page' do
        do_request

        expect(response).to render_template :show
      end
    end

    def do_request
      get :show
    end
  end
end
