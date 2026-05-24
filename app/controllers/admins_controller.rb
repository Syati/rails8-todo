class AdminsController < ApplicationController
  PER_PAGE = 30

  def index
    @q = Admin.ransack(search_params)
    admins = @q.result.order(id: :desc)
    @page = [ params.fetch(:page, 1).to_i, 1 ].max
    @admins = admins.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @has_next_page = admins.count > (@page * PER_PAGE)
  end

  private

  def search_params
    params.fetch(:q, ActionController::Parameters.new).permit(:id_eq, :email_cont)
  end
end
