# frozen_string_literal: true

class ApplicationController < ActionController::Base
  prepend_view_path Rails.root.join('frontend')

  include Authentication
end
