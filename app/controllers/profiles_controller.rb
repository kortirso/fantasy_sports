# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :find_identities, only: %i[show]

  def show; end

  private

  def find_identities
    @identities = current_user.identities.order(provider: :asc).hashable_pluck(:id, :provider, :created_at)
    @need_identities = Identity.providers.keys - @identities.pluck(:provider)
  end
end
