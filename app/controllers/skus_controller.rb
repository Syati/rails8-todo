class SkusController < ApplicationController
  before_action :set_product
  before_action :set_sku, only: %i[edit update destroy]

  def new
    @sku = @product.skus.build
  end

  def edit
  end

  def create
    @sku = @product.skus.build(sku_params)

    if @sku.save
      redirect_to @product, notice: t(".success", code: @sku.code)
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @sku.update(sku_params)
      redirect_to @product, notice: t(".success", code: @sku.code)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @sku.destroy!
    redirect_to @product, notice: t(".success", code: @sku.code)
  end

  private

  def set_product
    @product = Product.find(params.expect(:product_id))
  end

  def set_sku
    @sku = @product.skus.find(params.expect(:id))
  end

  def sku_params
    params.expect(sku: %i[code size color price_yen stock_quantity])
  end
end
