require "rails_helper"

RSpec.describe "Api::V1::Skus", type: :request do
  let(:product) { create(:product) }
  let(:headers) { api_headers(json: true) }
  let(:json) { response.parsed_body }

  describe "POST /api/v1/products/:product_id/skus" do
    it "SKU を追加して 201 で返す", :aggregate_failures do
      body = { code: "ts-s", size: "S", price_yen: 2_980 }

      expect { post api_v1_product_skus_path(product), params: body.to_json, headers: headers }
        .to change(product.skus, :count).by(1)

      expect(response).to conform_schema(201)
      expect(json).to include("code" => "TS-S", "size" => "S", "color" => nil, "price_yen" => 2_980, "stock_quantity" => 0)
    end

    it "負の在庫数や小数の価格は 422 を返す", :aggregate_failures do
      body = { code: "TS-S", price_yen: 12.5, stock_quantity: -1 }

      post api_v1_product_skus_path(product), params: body.to_json, headers: headers

      expect(response).to conform_response_schema(422)
      expect(json["errors"].keys).to contain_exactly("price_yen", "stock_quantity")
    end

    it "ない商品は 404 を返す" do
      post api_v1_product_skus_path(product_id: 0), params: { code: "TS-S", price_yen: 1 }.to_json, headers: headers

      expect(response).to conform_schema(404)
    end
  end

  describe "PATCH /api/v1/skus/:id" do
    let(:sku) { create(:sku, product: product, size: "M", color: "白", price_yen: 3_300) }

    it "送った項目だけを更新する", :aggregate_failures do
      patch api_v1_sku_path(sku), params: { price_yen: 2_980, color: nil }.to_json, headers: headers

      expect(response).to conform_schema(200)
      expect(sku.reload).to have_attributes(size: "M", color: nil, price_yen: 2_980)
    end

    it "同じ商品のサイズ・色と重なると 422 を返す" do
      create(:sku, product: product, size: "L", color: "白")

      patch api_v1_sku_path(sku), params: { size: "L" }.to_json, headers: headers

      expect(response).to conform_schema(422)
      expect(json["errors"]).to eq("size" => [ "はすでに存在します" ])
    end
  end

  describe "DELETE /api/v1/skus/:id" do
    it "SKU を削除して 204 を返す", :aggregate_failures do
      sku = create(:sku, product: product)

      expect { delete api_v1_sku_path(sku), headers: headers }.to change(Catalog::Sku, :count).by(-1)

      expect(response).to conform_schema(204)
    end
  end
end
