# Request body of POST /api/v1/products/:product_id/skus, and each element of skus[] in
# POST /api/v1/products. Matches V1.Skus.CreateRequest in api/openapi.yaml.
class Api::V1::Skus::CreateRequestParameter < StructuredParams::Params
  attribute :code, :string
  attribute :size, :string
  attribute :color, :string
  attribute :price_yen, :integer
  attribute :stock_quantity, :integer

  # Reject 12.5 or "12x" instead of letting the integer cast truncate them.
  validates_raw :price_yen, :stock_quantity, format: { with: /\A\d+\z/ }, allow_nil: true

  validates :code, presence: true, length: { maximum: 50 }
  validates :size, :color, length: { maximum: 30 }
  validates :price_yen, presence: true
end
