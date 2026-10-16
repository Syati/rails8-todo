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
FactoryBot.define do
  factory :sku, class: "Catalog::Sku" do
    product
    sequence(:code) { |n| "TS-#{n.to_s.rjust(4, '0')}" }
    size { "M" }
    sequence(:color) { |n| "カラー#{n}" }
    price_yen { 3_300 }
    stock_quantity { 10 }
  end
end
