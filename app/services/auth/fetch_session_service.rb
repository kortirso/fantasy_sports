# frozen_string_literal: true

module Auth
  class FetchSessionService
    include Deps[jwt_encoder: 'jwt_encoder']

    def call(token:)
      payload = extract_uuid(token)
      return { errors: [I18n.t('services.auth.fetch_session.forbidden')] } if payload.blank?

      session = find_session(payload)
      return { errors: [I18n.t('services.auth.fetch_session.forbidden')] } if session.blank?

      { result: session }
    end

    private

    def extract_uuid(token)
      jwt_encoder.decode(token)
    rescue JWT::DecodeError
      {}
    end

    def find_session(payload)
      Users::Session.where(uuid: payload.fetch('uuid', '')).first
    end
  end
end
