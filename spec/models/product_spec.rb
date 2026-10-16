require "rails_helper"

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
RSpec.describe Product do
  it "商品名がないと無効" do
    expect(build(:product, name: "")).not_to be_valid
  end

  it "初期値は下書きかつ標準税率", :aggregate_failures do
    product = described_class.new

    expect(product).to be_draft
    expect(product).to be_standard
  end

  it "税率は10と8を保存する", :aggregate_failures do
    expect(create(:product, tax_rate: :standard).tax_rate_before_type_cast).to eq(10)
    expect(create(:product, tax_rate: :reduced).tax_rate_before_type_cast).to eq(8)
  end

  it "削除すると SKU も削除する" do
    product = create(:product)
    create_list(:sku, 2, product: product)

    expect { product.destroy! }.to change(Sku, :count).by(-2)
  end
end
