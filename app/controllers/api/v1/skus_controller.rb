class Api::V1::SkusController < Api::V1::BaseController
  before_action :set_sku, only: %i[update destroy]

  def create
    product = Catalog::Product.find(params.expect(:product_id))
    request_params = Api::V1::Skus::CreateRequestParameter.new(params)
    return render_validation_errors(request_params.errors) if request_params.invalid?

    sku = product.skus.build(request_params.attributes(compact_mode: :nil_only))

    if sku.save
      render json: Api::V1::SkuSerializer.call(sku), status: :created
    else
      render_validation_errors(sku.errors)
    end
  end

  def update
    request_params = Api::V1::Skus::UpdateRequestParameter.new(params)
    return render_validation_errors(request_params.errors) if request_params.invalid?

    if @sku.update(sent_attributes(request_params))
      render json: Api::V1::SkuSerializer.call(@sku)
    else
      render_validation_errors(@sku.errors)
    end
  end

  def destroy
    @sku.destroy!
    head :no_content
  end

  private

  def set_sku
    @sku = Catalog::Sku.find(params.expect(:id))
  end
end
