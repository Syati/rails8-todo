class AdminsController < ApplicationController
  PER_PAGE = 30
  SORT_DIRECTIONS = %w[desc asc].freeze

  before_action :require_super_admin!, only: %i[new create]

  def index
    @search_query = search_params.to_h
    @q = Admin.ransack(@search_query)
    @sort = sort_direction
    @pagy, @admins = pagy(@q.result.order(id: @sort), limit: PER_PAGE)
  end

  def show
    @admin = Admin.find(params.expect(:id))
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(create_params)

    if @admin.save
      redirect_to @admin, notice: "管理者を作成しました。確認メールを #{@admin.email} に送信しました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def require_super_admin!
    return if current_admin.super_admin?

    render "shared/forbidden", status: :forbidden
  end

  def search_params
    params.fetch(:q, ActionController::Parameters.new).permit(:id_eq, :email_cont)
  end

  def create_params
    params.expect(admin: %i[email password password_confirmation])
  end

  def sort_direction
    SORT_DIRECTIONS.include?(params[:sort]) ? params[:sort] : SORT_DIRECTIONS.first
  end
end
