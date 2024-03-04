# frozen_string_literal: true

shared_examples_for 'required available email' do
  context 'for banned users' do
    sign_in_banned_user

    it 'redirects to home page' do
      do_request

      expect(response).to redirect_to root_en_path
    end
  end
end
