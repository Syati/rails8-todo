require "rails_helper"

RSpec.describe "Api::V1::Products", type: :request do
  let(:headers) { api_headers }
  let(:json) { response.parsed_body }

  def post_json(path, body)
    post path, params: body.to_json, headers: headers.merge("Content-Type" => "application/json")
  end

  def patch_json(path, body)
    patch path, params: body.to_json, headers: headers.merge("Content-Type" => "application/json")
  end

  describe "GET /api/v1/products" do
    it "商品を id の降順で、SKU とページ情報つきで返す", :aggregate_failures do
      older = create(:product)
      newer = create(:product)
      sku = create(:sku, product: newer, code: "TS-0001")

      get api_v1_products_path, headers: headers

      expect(response).to conform_schema(200)
      expect(json["products"].pluck("id")).to eq([ newer.id, older.id ])
      expect(json["products"].first["skus"]).to eq([
        { "id" => sku.id, "code" => "TS-0001", "size" => "M", "color" => sku.color, "price_yen" => 3_300, "stock_quantity" => 10 }
      ])
      expect(json["pagination"]).to eq("page" => 1, "per_page" => 30, "count" => 2, "pages" => 1)
    end

    it "商品名の部分一致と、複数の販売状態で絞り込む" do
      tea = create(:product, name: "有機緑茶", status: :on_sale)
      draft_tea = create(:product, name: "有機ほうじ茶", status: :draft)
      create(:product, name: "有機麦茶", status: :discontinued)
      create(:product, name: "コーヒー豆", status: :on_sale)

      get api_v1_products_path, params: { q: "有機", status: %w[on_sale draft] }, headers: headers

      expect(response).to conform_schema(200)
      expect(json["products"].pluck("id")).to contain_exactly(tea.id, draft_tea.id)
    end

    it "per_page と page でページを分ける" do
      products = create_list(:product, 3)

      get api_v1_products_path, params: { page: 2, per_page: 2 }, headers: headers

      expect(json).to include(
        "products" => [ a_hash_including("id" => products.first.id) ],
        "pagination" => { "page" => 2, "per_page" => 2, "count" => 3, "pages" => 2 }
      )
    end

    it "不正なクエリは 422 を返す", :aggregate_failures do
      get api_v1_products_path, params: { per_page: 101, status: %w[unknown] }, headers: headers

      expect(response).to conform_response_schema(422)
      expect(json["errors"].keys).to contain_exactly("per_page", "status")
    end

    it "トークンがなければ 401 を返す", :aggregate_failures do
      get api_v1_products_path

      expect(response).to conform_schema(401)
      expect(json).to eq("error" => "unauthorized")
    end
  end

  describe "GET /api/v1/products/:id" do
    it "商品を返す" do
      product = create(:product, description: nil, tax_rate: :reduced)

      get api_v1_product_path(product), headers: headers

      expect(response).to conform_schema(200)
      expect(json).to include("id" => product.id, "description" => nil, "tax_rate" => "reduced", "skus" => [])
    end

    it "ない商品は 404 を返す", :aggregate_failures do
      get api_v1_product_path(0), headers: headers

      expect(response).to conform_schema(404)
      expect(json).to eq("error" => "not_found")
    end
  end

  describe "POST /api/v1/products" do
    let(:body) do
      {
        name: "オーガニックコットン T シャツ",
        tax_rate: "standard",
        skus: [
          { code: "ts-m-white", size: "M", color: "白", price_yen: 3_300, stock_quantity: 5 },
          { code: "TS-L-WHITE", size: "L", color: "白", price_yen: 3_300 }
        ]
      }
    end

    it "商品と SKU を登録し、201 で返す", :aggregate_failures do
      expect { post_json api_v1_products_path, body }
        .to change(Catalog::Product, :count).by(1).and change(Catalog::Sku, :count).by(2)

      expect(response).to conform_schema(201)
      expect(json).to include("name" => "オーガニックコットン T シャツ", "status" => "draft", "description" => nil)
      expect(json["skus"]).to match([
        a_hash_including("code" => "TS-M-WHITE", "stock_quantity" => 5),
        a_hash_including("code" => "TS-L-WHITE", "stock_quantity" => 0)
      ])
    end

    it "入力の誤りを項目ごとにネストして 422 で返し、何も登録しない", :aggregate_failures do
      body[:name] = ""
      body[:status] = "sold_out"
      body[:skus][1].merge!(code: nil, price_yen: "12x")

      expect { post_json api_v1_products_path, body }.not_to change(Catalog::Product, :count)

      expect(response).to conform_response_schema(422)
      expect(json["errors"]).to match(
        "name" => [ "を入力してください" ],
        "status" => [ "は一覧にありません" ],
        "skus" => { "1" => { "code" => [ "を入力してください" ], "price_yen" => [ "は不正な値です" ] } }
      )
    end

    it "リクエスト内で重複する SKU コードとサイズ・色を 422 にする" do
      body[:skus][1].merge!(code: "TS-m-White", size: "M")

      post_json api_v1_products_path, body

      expect(response).to conform_schema(422)
      expect(json["errors"]).to eq(
        "skus" => { "1" => { "code" => [ "はすでに存在します" ], "size" => [ "はすでに存在します" ] } }
      )
    end

    it "登録済みの SKU コードはモデルの検証で 422 にする", :aggregate_failures do
      create(:sku, code: "TS-L-WHITE")

      post_json api_v1_products_path, body

      expect(response).to conform_schema(422)
      expect(json["errors"]).to eq("skus" => { "1" => { "code" => [ "はすでに存在します" ] } })
    end

    it "JSON 以外は 415 を返す", :aggregate_failures do
      expect { post api_v1_products_path, params: body, headers: headers }.not_to change(Catalog::Product, :count)

      expect(response).to conform_response_schema(415)
    end
  end

  describe "PATCH /api/v1/products/:id" do
    let(:product) { create(:product, name: "旧名", description: "説明", status: :draft) }

    it "送った項目だけを更新する", :aggregate_failures do
      patch_json api_v1_product_path(product), { status: "on_sale", description: nil }

      expect(response).to conform_schema(200)
      expect(product.reload).to have_attributes(name: "旧名", description: nil, status: "on_sale")
    end

    it "商品名を null にすると 422 を返す", :aggregate_failures do
      patch_json api_v1_product_path(product), { name: nil }

      expect(response).to conform_response_schema(422)
      expect(json["errors"]).to eq("name" => [ "を入力してください" ])
    end
  end

  describe "DELETE /api/v1/products/:id" do
    it "商品を SKU ごと削除して 204 を返す", :aggregate_failures do
      product = create(:sku).product

      expect { delete api_v1_product_path(product), headers: headers }
        .to change(Catalog::Product, :count).by(-1).and change(Catalog::Sku, :count).by(-1)

      expect(response).to conform_schema(204)
    end
  end
end
