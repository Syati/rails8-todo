class AdminsController < ApplicationController
  PER_PAGE = 30
  SORT_DIRECTIONS = %w[desc asc].freeze

  before_action :require_super_admin!, only: %i[new create edit update]
  before_action :set_admin, only: %i[show edit update]

  def index
    @search_query = search_params.to_h
    @q = Admin.ransack(@search_query)
    @sort = sort_direction
    @pagy, @admins = pagy(@q.result.order(id: @sort), limit: PER_PAGE)
  end

  def show
  end

  def new
    @admin = Admin.new
  end

  def edit
  end
  def create
    @admin = Admin.new(create_params)

    if @admin.save
      redirect_to @admin, notice: "管理者を作成しました。確認メールを #{@admin.email} に送信しました。"
    else
      render :new, status: :unprocessable_content
    end
  end


  def update
    if @admin.update(update_params)
      redirect_to @admin, notice: update_notice
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_admin
    @admin = Admin.find(params.expect(:id))
  end

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

  # A blank password keeps the current one. Admins cannot change their own role,
  # so the last super_admin cannot demote themselves by mistake.
  def update_params
    permitted = params.expect(admin: %i[email role password password_confirmation])
    permitted.delete(:role) if @admin == current_admin
    if permitted[:password].blank?
      permitted.delete(:password)
      permitted.delete(:password_confirmation)
    end
    permitted
  end

  def update_notice
    return "管理者を更新しました。" unless @admin.saved_change_to_unconfirmed_email? && @admin.unconfirmed_email.present?

    "管理者を更新しました。新しいメールアドレス #{@admin.unconfirmed_email} に確認メールを送信しました。"
  end

  def sort_direction
    SORT_DIRECTIONS.include?(params[:sort]) ? params[:sort] : SORT_DIRECTIONS.first
  end
end
