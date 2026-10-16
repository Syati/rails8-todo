# == Schema Information
#
# Table name: skus
#
#  id             :bigint           not null, primary key
#  code           :string           not null
#  color          :string
#  price_yen      :integer          not null
#  size           :string
#  stock_quantity :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  product_id     :bigint           not null
#
# Indexes
#
#  index_skus_on_code                           (code) UNIQUE
#  index_skus_on_product_id_and_size_and_color  (product_id,size,color) UNIQUE NULLS NOT DISTINCT
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class Sku < ApplicationRecord
  CODE_FORMAT = /\A[A-Z0-9][A-Z0-9-]*\z/
  MAX_PRICE_YEN = 10_000_000

  belongs_to :product, inverse_of: :skus

  # Codes are printed on labels and typed in by hand, so normalize them to upper case.
  normalizes :code, with: ->(code) { code.strip.upcase }
  normalizes :size, :color, with: ->(value) { value.strip.presence }

  validates :code, presence: true, length: { maximum: 50 }, uniqueness: true,
                   format: { with: CODE_FORMAT, allow_blank: true }
  validates :size, :color, length: { maximum: 30 }
  validates :size, uniqueness: { scope: %i[product_id color] }
  validates :price_yen, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PRICE_YEN }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def variant_label
    [ size, color ].compact.join(" / ").presence || "単一"
  end
end
