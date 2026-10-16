require "rails_helper"

# == Schema Information
#
# Table name: catalog_skus
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
#  index_catalog_skus_on_code                           (code) UNIQUE
#  index_catalog_skus_on_product_id_and_size_and_color  (product_id,size,color) UNIQUE NULLS NOT DISTINCT
#
# Foreign Keys
#
#  fk_rails_...  (product_id => catalog_products.id)
#
RSpec.describe Catalog::Sku do
  describe "normalization" do
    it "SKU コードの前後の空白を除いて大文字にする" do
      expect(build(:sku, code: " ts-001-m ").code).to eq("TS-001-M")
    end

    it "空欄のサイズと色は nil にする", :aggregate_failures do
      sku = build(:sku, size: " ", color: "")

      expect(sku.size).to be_nil
      expect(sku.color).to be_nil
    end
  end

  describe "validations" do
    it "英大文字・数字・ハイフン以外の SKU コードは無効" do
      sku = build(:sku, code: "TS_001")

      expect(sku).not_to be_valid
      expect(sku.errors[:code]).to be_present
    end

    it "SKU コードは商品をまたいで一意" do
      create(:sku, code: "TS-001")

      expect(build(:sku, code: "ts-001")).not_to be_valid
    end

    it "同じ商品でサイズと色の組み合わせが重複すると無効" do
      existing = create(:sku, size: "M", color: "ホワイト")

      expect(build(:sku, product: existing.product, size: "M", color: "ホワイト")).not_to be_valid
    end

    it "サイズも色もない SKU は商品ごとに1つまで" do
      existing = create(:sku, size: nil, color: nil)

      expect(build(:sku, product: existing.product, size: nil, color: nil)).not_to be_valid
    end

    it "別の商品なら同じサイズと色を使える" do
      create(:sku, size: "M", color: "ホワイト")

      expect(build(:sku, size: "M", color: "ホワイト")).to be_valid
    end

    it "価格と在庫数は0以上の整数", :aggregate_failures do
      expect(build(:sku, price_yen: -1)).not_to be_valid
      expect(build(:sku, price_yen: 1.5)).not_to be_valid
      expect(build(:sku, stock_quantity: -1)).not_to be_valid
      expect(build(:sku, price_yen: 0, stock_quantity: 0)).to be_valid
    end

    it "価格の上限は1,000万円" do
      expect(build(:sku, price_yen: Catalog::Sku::MAX_PRICE_YEN + 1)).not_to be_valid
    end
  end

  describe "#variant_label" do
    it "サイズと色をつなげて返し、どちらもなければ「単一」を返す", :aggregate_failures do
      expect(build(:sku, size: "M", color: "ホワイト").variant_label).to eq("M / ホワイト")
      expect(build(:sku, size: nil, color: "ホワイト").variant_label).to eq("ホワイト")
      expect(build(:sku, size: nil, color: nil).variant_label).to eq("単一")
    end
  end
end
