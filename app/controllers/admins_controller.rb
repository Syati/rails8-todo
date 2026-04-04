class AdminsController < ApplicationController
  PER_PAGE = 30

  def index
    @page = [ params.fetch(:page, 1).to_i, 1 ].max
    @admins = Admin.order(id: :desc).offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @has_next_page = Admin.count > (@page * PER_PAGE)
  end
end
