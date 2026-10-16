# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  status      :integer          default(0), not null
#  tax_rate    :integer          default(10), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_products_on_status  (status)
#
FactoryBot.define do
  factory :product, class: "Catalog::Product" do
    sequence(:name) { |n| "オーガニックコットン T シャツ #{n}" }
    description { "厚手の綿 100% の T シャツ。" }
    status { :on_sale }
    tax_rate { :standard }
  end
end
