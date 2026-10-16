# Query string of GET /api/v1/products. OpenAPI describes it as parameters rather than a
# component schema, so the drift check skips it (see config/initializers/structured_params_openapi.rb).
class Api::V1::Products::IndexQueryParameter < StructuredParams::Params
  MAX_PER_PAGE = 100

  attribute :q, :string
  attribute :status, :array, value_type: :string
  attribute :page, :integer, default: 1
  attribute :per_page, :integer, default: 30

  validates_raw :page, :per_page, format: { with: /\A\d+\z/ }, allow_nil: true

  validates :page, numericality: { greater_than_or_equal_to: 1 }
  validates :per_page, numericality: { in: 1..MAX_PER_PAGE }
  validate :statuses_known

  private

  def statuses_known
    return if (Array(status) - Catalog::Product.statuses.keys).empty?

    errors.add(:status, :inclusion)
  end
end
