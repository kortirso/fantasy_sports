# frozen_string_literal: true

module Api
  module V1
    class UserSerializer < ApplicationSerializer
      extend Helpers::AccessToken

      set_id nil

      attribute :confirmed, &:confirmed?
      attribute :banned, &:banned?

      attribute :access_token, if: proc { |_, params| params[:access_token] } do |object|
        generate_token_service.call(user: object)[:result]
      end
    end
  end
end
