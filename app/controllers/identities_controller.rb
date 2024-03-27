# frozen_string_literal: true

class IdentitiesController < ApplicationController
  before_action :find_identity, only: %i[destroy]

  def destroy
    ActiveRecord::Base.transaction do
      @identity.destroy
      Current.user.notifications.where(target: @identity.provider).destroy_all
    end
    redirect_to profile_path
  end

  private

  def find_identity
    @identity = Current.user.identities.find_by(id: params[:id])
    redirect_to profile_path if @identity.nil?
  end
end
