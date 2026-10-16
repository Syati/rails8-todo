# Request body of PATCH /api/v1/products/:id. Matches V1.Products.UpdateRequest in api/openapi.yaml.
class Api::V1::Products::UpdateRequestParameter < StructuredParams::Params
  attribute :name, :string
  attribute :description, :string
  attribute :status, :string
  attribute :tax_rate, :string

  validates :name, length: { maximum: 100 }
  validates :description, length: { maximum: 2000 }
  validates :status, inclusion: { in: Catalog::Product.statuses.keys }, allow_nil: true
  validates :tax_rate, inclusion: { in: Catalog::Product.tax_rates.keys }, allow_nil: true
end
