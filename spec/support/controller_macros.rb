# frozen_string_literal: true

module ControllerMacros
  def sign_in_admin
    before do
      @current_user = create :user, role: 'admin'
      @request.session['fantasy_sports_token'] =
        FantasySports::Container['services.auth.generate_token'].call(user: @current_user)[:result]
    end
  end

  def sign_in_user
    before do
      @current_user = create :user
      @request.session['fantasy_sports_token'] =
        FantasySports::Container['services.auth.generate_token'].call(user: @current_user)[:result]
    end
  end

  def sign_in_unconfirmed_user
    before do
      @current_user = create :user, :not_confirmed
      @request.session['fantasy_sports_token'] =
        FantasySports::Container['services.auth.generate_token'].call(user: @current_user)[:result]
    end
  end
end
