# frozen_string_literal: true

module Auth
  class GenerateTokenService
    include Deps[jwt_encoder: 'jwt_encoder']

    def call(user:)
      Users::Session.where(user: user).destroy_all
      { result: jwt_encoder.encode(uuid: Users::Session.create!(user: user).uuid) }
    end
  end
end
