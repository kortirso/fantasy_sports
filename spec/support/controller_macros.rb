# frozen_string_literal: true

module ControllerMacros
  def sign_in_user
    before do
      @current_user = create :user
      @request.session['fantasy_sports_user_id'] = @current_user.id
    end
  end
end
