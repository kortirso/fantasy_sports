# frozen_string_literal: true

shared_examples_for 'required api available email' do
  context 'for unconfirmed users' do
    sign_in_api_banned_user

    it 'renders forbidden error' do
      do_request(FantasySports::Container['services.auth.generate_token'].call(user: @current_user)[:result])

      expect(response).to have_http_status :forbidden
    end
  end
end
