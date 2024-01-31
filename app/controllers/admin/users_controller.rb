# frozen_string_literal: true

module Admin
  class UsersController < AdminController
    before_action :find_users, only: %i[index]

    def index; end

    private

    def find_users
      @users = User.order(id: :desc)
    end
  end
end
