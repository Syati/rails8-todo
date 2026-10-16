require "rails_helper"

RSpec.describe "Console::Products", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:operator) { create(:admin) }
  let(:valid_params) { { product: { name: "有機緑茶 100g", description: "静岡県産", status: "on_sale", tax_rate: "reduced" } } }

  before { sign_in operator }

  describe "GET /console/products" do
    it "商品を id 降順で表示し、SKU 数・価格帯・在庫合計を出す", :aggregate_failures do
      older = create(:product, name: "古い商品")
      newer = create(:product, name: "新しい商品")
      create(:sku, product: newer, price_yen: 1_980, stock_quantity: 3)
      create(:sku, product: newer, price_yen: 2_480, stock_quantity: 4)

      get console_products_path

      expect(response).to have_http_status(:ok)
      expect(response.body.index("新しい商品")).to be < response.body.index("古い商品")
      expect(response.body).to include("¥1,980〜¥2,480")
      expect(response.body).to include(">7</td>")
      expect(older).to be_persisted
    end

    it "商品名の部分一致と販売状態で絞り込む", :aggregate_failures do
      create(:product, name: "有機緑茶", status: :on_sale)
      create(:product, name: "有機ほうじ茶", status: :discontinued)
      create(:product, name: "コーヒー豆", status: :on_sale)

      get console_products_path, params: { q: { name_cont: "有機", status_eq: Catalog::Product.statuses[:on_sale] } }

      expect(response.body).to include("有機緑茶")
      expect(response.body).not_to include("有機ほうじ茶")
      expect(response.body).not_to include("コーヒー豆")
    end

    it "30件ごとにページを分ける" do
      create_list(:product, 31) # rubocop:disable FactoryBot/ExcessiveCreateList

      get console_products_path, params: { page: 2 }

      expect(response.body).to include(">#{Catalog::Product.minimum(:id)}</td>")
    end

    it "未ログインはログイン画面へリダイレクトする" do
      sign_out operator

      get console_products_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "GET /console/products/:id" do
    it "商品と SKU を表示する", :aggregate_failures do
      product = create(:product, name: "有機緑茶 100g", tax_rate: :reduced)
      create(:sku, product: product, code: "TEA-100", price_yen: 1_080, stock_quantity: 0)

      get console_product_path(product)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("有機緑茶 100g", "軽減税率 8%", "TEA-100", "¥1,080", "在庫切れ")
    end

    it "存在しない商品は404になる" do
      get console_product_path(id: 0)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /console/products" do
    it "operator も商品を登録できる", :aggregate_failures do
      expect { post console_products_path, params: valid_params }.to change(Catalog::Product, :count).by(1)

      product = Catalog::Product.last
      expect(product).to have_attributes(name: "有機緑茶 100g", status: "on_sale", tax_rate: "reduced")
      expect(response).to redirect_to(console_product_path(product))
      expect(flash[:notice]).to include("有機緑茶 100g")
    end

    it "商品名がないと422でフォームを再表示する", :aggregate_failures do
      expect { post console_products_path, params: { product: valid_params[:product].merge(name: "") } }.not_to change(Catalog::Product, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("商品の新規登録")
    end

    it "存在しない販売状態は登録しない" do
      post console_products_path, params: { product: valid_params[:product].merge(status: "unknown") }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /console/products/:id" do
    it "商品を更新する", :aggregate_failures do
      product = create(:product)

      patch console_product_path(product), params: { product: { name: "改名した商品", status: "discontinued" } }

      expect(product.reload).to have_attributes(name: "改名した商品", status: "discontinued")
      expect(response).to redirect_to(console_product_path(product))
    end

    it "不正な値なら422でフォームを再表示する" do
      product = create(:product)

      patch console_product_path(product), params: { product: { name: "" } }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /console/products/:id" do
    it "商品と SKU を削除して一覧へ戻る", :aggregate_failures do
      product = create(:product, name: "削除する商品")
      create(:sku, product: product)

      expect { delete console_product_path(product) }.to change(Catalog::Product, :count).by(-1).and change(Catalog::Sku, :count).by(-1)
      expect(response).to redirect_to(console_products_path)
      expect(flash[:notice]).to include("削除する商品")
    end
  end
end
