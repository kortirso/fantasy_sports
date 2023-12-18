# frozen_string_literal: true

class IdentitiesController < ApplicationController
  before_action :find_identity, only: %i[destroy]

  def destroy
    @identity.destroy
    redirect_to profile_path
  end

  private

  def find_identity
    @identity = current_user.identities.find_by(id: params[:id])
    redirect_to profile_path if @identity.nil?
  end
end
