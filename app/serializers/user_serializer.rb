# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  extend Helpers::AccessToken

  set_id { SecureRandom.hex }

  attribute :email, if: proc { |_, params| required_field?(params, 'email') }, &:email
  attribute :confirmed, if: proc { |_, params| required_field?(params, 'confirmed') }, &:confirmed?
  attribute :banned, if: proc { |_, params| required_field?(params, 'banned') }, &:banned?

  attribute :access_token, if: proc { |_, params| required_field?(params, 'access_token') } do |object|
    generate_token_service.call(user: object)[:result]
  end
end
