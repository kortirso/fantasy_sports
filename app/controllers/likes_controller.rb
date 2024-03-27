# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :find_likeable, only: %i[create]
  before_action :find_like, only: %i[destroy]

  def create
    Current.user.likes.find_or_create_by(likeable: @likeable)
    redirect_to params[:redirect] == 'draft_players' ? draft_players_path : oracul_places_path
  end

  def destroy
    @like.destroy
    redirect_to params[:redirect] == 'draft_players' ? draft_players_path : oracul_places_path
  end

  private

  def find_likeable
    @likeable =
      case params[:likeable_type]
      when 'Season' then Season.find_by(id: params[:likeable_id])
      when 'Cup' then Cup.find_by(id: params[:likeable_id])
      end

    page_not_found if @likeable.nil?
  end

  def find_like
    @like = Current.user.likes.find(params[:id])
  end
end
