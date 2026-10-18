class Api::V1::ProductsController < Api::V1::BaseController
  before_action :set_product, only: %i[show update destroy]

  def index
    query = Api::V1::Products::IndexQueryParameter.new(params)
    return render_validation_errors(query.errors) if query.invalid?

    pagy, products = pagy(search(query).includes(:skus).order(id: :desc), limit: query.per_page, page: query.page)
    render json: { products: Api::V1::ProductResource.new(products).to_h, pagination: Api::V1::PaginationResource.new(pagy).to_h }
  end

  def show
    render json: Api::V1::ProductResource.new(@product).to_h
  end

  def create
    request_params = Api::V1::Products::CreateRequestParameter.new(params)
    return render_validation_errors(request_params.errors) if request_params.invalid?

    # Leave out nil so the model defaults (draft, standard, stock 0) apply.
    product = Catalog::Product.new(request_params.attributes(compact_mode: :nil_only).except("skus"))
    Array(request_params.skus).each { |sku| product.skus.build(sku.attributes(compact_mode: :nil_only)) }

    if product.save
      render json: Api::V1::ProductResource.new(product).to_h, status: :created
    else
      render_validation_errors(product.errors)
    end
  end

  def update
    request_params = Api::V1::Products::UpdateRequestParameter.new(params)
    return render_validation_errors(request_params.errors) if request_params.invalid?

    if @product.update(sent_attributes(request_params))
      render json: Api::V1::ProductResource.new(@product).to_h
    else
      render_validation_errors(@product.errors)
    end
  end

  def destroy
    @product.destroy!
    head :no_content
  end

  private

  def set_product
    @product = Catalog::Product.find(params.expect(:id))
  end

  def search(query)
    scope = Catalog::Product.all
    scope = scope.where("name ILIKE ?", "%#{Catalog::Product.sanitize_sql_like(query.q)}%") if query.q.present?
    scope = scope.where(status: query.status) if query.status.present?
    scope
  end
end
