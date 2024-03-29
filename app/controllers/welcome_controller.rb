# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :authenticate
  skip_before_action :check_email_ban

  def index; end

  def privacy; end
end
