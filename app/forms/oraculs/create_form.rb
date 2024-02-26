# frozen_string_literal: true

module Oraculs
  class CreateForm
    include Deps[validator: 'validators.oracul']

    def call(user:, oracul_place:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      result = user.oraculs.create!(params.merge(oracul_place: oracul_place))
      connect_oracul_with_delphi_league(result, oracul_place)

      { result: result }
    rescue ActiveRecord::RecordNotUnique => _e
      { errors: [I18n.t('services.oraculs.create.not_unique')] }
    end

    private

    def connect_oracul_with_delphi_league(oracul, oracul_place)
      oracul_place.oracul_leagues.general.find_by(name: 'Delphi').oracul_leagues_members.create!(oracul: oracul)
    end
  end
end
