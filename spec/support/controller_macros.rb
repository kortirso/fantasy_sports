# frozen_string_literal: true

module ControllerMacros
  def sign_in_user
    before do
      user = create :user
      @request.session['fantasy_sports_user_id'] = user.id
    end
  end
end
