class AdminsController < ApplicationController
  PER_PAGE = 30
  SORT_DIRECTIONS = %w[desc asc].freeze

  def index
    @search_query = search_params.to_h
    @q = Admin.ransack(@search_query)
    @sort = sort_direction
    @pagy, @admins = pagy(@q.result.order(id: @sort), limit: PER_PAGE)
  end

  private

  def search_params
    params.fetch(:q, ActionController::Parameters.new).permit(:id_eq, :email_cont)
  end

  def sort_direction
    SORT_DIRECTIONS.include?(params[:sort]) ? params[:sort] : SORT_DIRECTIONS.first
  end
end
