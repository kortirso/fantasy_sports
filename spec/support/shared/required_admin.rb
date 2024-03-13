# frozen_string_literal: true

shared_examples_for 'required admin' do
  context 'for confirmed users' do
    sign_in_user

    it 'redirects' do
      do_request

      expect(response).to redirect_to draft_players_path
    end
  end
end
