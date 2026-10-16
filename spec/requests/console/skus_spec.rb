require "rails_helper"

RSpec.describe "Console::Skus", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:product) { create(:product) }
  let(:valid_params) { { sku: { code: "ts-org-m-wht", size: "M", color: "ホワイト", price_yen: "3300", stock_quantity: "12" } } }

  before { sign_in create(:admin) }

  describe "GET /console/products/:product_id/skus/new" do
    it "追加フォームを表示する" do
      get new_console_product_sku_path(product)

      expect(response.body).to include("SKU の追加", product.name)
    end
  end

  describe "POST /console/products/:product_id/skus" do
    it "SKU を追加して商品詳細へ戻る", :aggregate_failures do
      expect { post console_product_skus_path(product), params: valid_params }.to change(product.skus, :count).by(1)

      expect(product.skus.last).to have_attributes(code: "TS-ORG-M-WHT", price_yen: 3_300, stock_quantity: 12)
      expect(response).to redirect_to(console_product_path(product))
      expect(flash[:notice]).to eq("SKU TS-ORG-M-WHT を追加しました。")
    end

    it "SKU コードが重複すると422でフォームを再表示する", :aggregate_failures do
      create(:sku, code: "TS-ORG-M-WHT")

      expect { post console_product_skus_path(product), params: valid_params }.not_to change(Catalog::Sku, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("すでに存在します")
    end

    it "負の在庫数は追加しない" do
      post console_product_skus_path(product), params: { sku: valid_params[:sku].merge(stock_quantity: "-1") }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /console/products/:product_id/skus/:id" do
    it "価格と在庫数を更新する", :aggregate_failures do
      sku = create(:sku, product: product)

      patch console_product_sku_path(product, sku), params: { sku: { price_yen: "2980", stock_quantity: "0" } }

      expect(sku.reload).to have_attributes(price_yen: 2_980, stock_quantity: 0)
      expect(response).to redirect_to(console_product_path(product))
    end

    it "別の商品の SKU は404になる" do
      other_sku = create(:sku)

      patch console_product_sku_path(product, other_sku), params: { sku: { price_yen: "1" } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /console/products/:product_id/skus/:id" do
    it "SKU を削除して商品詳細へ戻る", :aggregate_failures do
      sku = create(:sku, product: product, code: "TS-DEL")

      expect { delete console_product_sku_path(product, sku) }.to change(Catalog::Sku, :count).by(-1)
      expect(response).to redirect_to(console_product_path(product))
      expect(flash[:notice]).to eq("SKU TS-DEL を削除しました。")
    end
  end
end
