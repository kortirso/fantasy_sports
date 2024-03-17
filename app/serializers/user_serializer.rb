# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  extend Helpers::AccessToken

  set_id { SecureRandom.hex }

  attribute :email, if: proc { |_, params| required_field?(params, 'email') }, &:email
  attribute :locale, if: proc { |_, params| required_field?(params, 'locale') }, &:locale
  attribute :confirmed, if: proc { |_, params| required_field?(params, 'confirmed') }, &:confirmed?
  attribute :banned, if: proc { |_, params| required_field?(params, 'banned') }, &:banned?

  attribute :access_token, if: proc { |_, params| required_field?(params, 'access_token') } do |object|
    generate_token_service.call(user: object)[:result]
  end

  attribute :gravatar, if: proc { |_, params| required_field?(params, 'gravatar') } do |object|
    "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(object.email)}"
  end
end
