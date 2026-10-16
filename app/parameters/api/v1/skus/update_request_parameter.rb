# Request body of PATCH /api/v1/skus/:id. Matches V1.Skus.UpdateRequest in api/openapi.yaml.
class Api::V1::Skus::UpdateRequestParameter < StructuredParams::Params
  attribute :code, :string
  attribute :size, :string
  attribute :color, :string
  attribute :price_yen, :integer
  attribute :stock_quantity, :integer

  validates_raw :price_yen, :stock_quantity, format: { with: /\A\d+\z/ }, allow_nil: true

  validates :code, length: { maximum: 50 }
  validates :size, :color, length: { maximum: 30 }
end
