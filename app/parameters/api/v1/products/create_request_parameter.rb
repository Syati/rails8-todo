# Request body of POST /api/v1/products. Matches V1.Products.CreateRequest in api/openapi.yaml.
class Api::V1::Products::CreateRequestParameter < StructuredParams::Params
  MAX_SKUS = 50

  attribute :name, :string
  attribute :description, :string
  attribute :status, :string
  attribute :tax_rate, :string
  attribute :skus, :array, value_class: Api::V1::Skus::CreateRequestParameter

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 2000 }
  validates :status, inclusion: { in: Catalog::Product.statuses.keys }, allow_nil: true
  validates :tax_rate, inclusion: { in: Catalog::Product.tax_rates.keys }, allow_nil: true
  validates :skus, length: { maximum: MAX_SKUS }
  # The model checks these against saved SKUs only, so catch duplicates within one request here.
  validate :sku_codes_unique, :sku_variants_unique

  private

  def sku_codes_unique
    add_duplicate_errors(:code) { |sku| sku.code&.strip&.upcase }
  end

  def sku_variants_unique
    add_duplicate_errors(:size) { |sku| [ sku.size&.strip.presence, sku.color&.strip.presence ] }
  end

  def add_duplicate_errors(attribute)
    keys = Array(skus).map { |sku| yield sku }
    keys.each_with_index do |key, index|
      next if keys.index(key) == index

      # A symbol type would make ActiveModel read the value through "skus.0.code", which
      # is not a method, so pass the message itself.
      errors.add(:"skus.#{index}.#{attribute}", I18n.t("errors.messages.taken"))
    end
  end
end
