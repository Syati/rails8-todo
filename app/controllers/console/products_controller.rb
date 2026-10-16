class Console::ProductsController < ApplicationController
  PER_PAGE = 30
  SORT_DIRECTIONS = %w[desc asc].freeze

  before_action :set_product, only: %i[show edit update destroy]

  def index
    @search_query = search_params.to_h
    @q = Catalog::Product.ransack(@search_query)
    @sort = sort_direction
    @pagy, @products = pagy(@q.result.includes(:skus).order(id: @sort), limit: PER_PAGE)
  end

  def show
  end

  def new
    @product = Catalog::Product.new
  end

  def edit
  end

  def create
    @product = Catalog::Product.new(product_params)

    if @product.save
      redirect_to [ :console, @product ], notice: t(".success", name: @product.name)
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @product.update(product_params)
      redirect_to [ :console, @product ], notice: t(".success")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @product.destroy!
    redirect_to console_products_path, notice: t(".success", name: @product.name)
  end

  private

  def set_product
    @product = Catalog::Product.find(params.expect(:id))
  end

  def search_params
    params.fetch(:q, ActionController::Parameters.new).permit(:id_eq, :name_cont, :status_eq)
  end

  def product_params
    params.expect(product: %i[name description status tax_rate])
  end

  def sort_direction
    SORT_DIRECTIONS.include?(params[:sort]) ? params[:sort] : SORT_DIRECTIONS.first
  end
end
