class AdminsController < ApplicationController
  PER_PAGE = 30
  SORT_DIRECTIONS = %w[desc asc].freeze

  def index
    @search_query = search_params.to_h
    @q = Admin.ransack(@search_query)
    @sort = sort_direction
    admins = @q.result.order(id: @sort)
    @page = [ params.fetch(:page, 1).to_i, 1 ].max
    @admins = admins.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @has_next_page = admins.count > (@page * PER_PAGE)
  end

  private

  def search_params
    params.fetch(:q, ActionController::Parameters.new).permit(:id_eq, :email_cont)
  end

  def sort_direction
    SORT_DIRECTIONS.include?(params[:sort]) ? params[:sort] : SORT_DIRECTIONS.first
  end
end
