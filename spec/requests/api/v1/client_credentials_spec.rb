require "rails_helper"

RSpec.describe "Api::V1 client credentials", type: :request do
  include Devise::Test::IntegrationHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:application) { create(:oauth_application) }
  let(:json) { response.parsed_body }

  # Hashed secrets can't be read back, so keep the plain one from creation.
  def issue_token(scope: nil)
    post oauth_token_path, params: {
      grant_type: "client_credentials", client_id: application.uid, client_secret: application.plaintext_secret, scope:
    }.compact
    response.parsed_body["access_token"]
  end

  def bearer(token)
    { "Authorization" => "Bearer #{token}" }
  end

  describe "POST /oauth/token" do
    it "client credentials で read スコープのトークンを発行する", :aggregate_failures do
      issue_token

      expect(response).to have_http_status(:ok)
      expect(json).to include("token_type" => "Bearer", "scope" => "read", "expires_in" => 7200)
    end

    it "secret が違うと発行しない" do
      post oauth_token_path, params: { grant_type: "client_credentials", client_id: application.uid, client_secret: "wrong" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/products" do
    it "read スコープのトークンで呼べる" do
      get api_v1_products_path, headers: bearer(issue_token)

      expect(response).to conform_schema(200)
    end

    it "失効したトークンは、セッションがあっても 401 を返す", :aggregate_failures do
      token = issue_token
      Doorkeeper::AccessToken.last.revoke
      sign_in create(:admin)

      get api_v1_products_path, headers: bearer(token)

      expect(response).to conform_schema(401)
      expect(response.headers["WWW-Authenticate"]).to eq(%(Bearer error="invalid_token"))
    end

    it "期限切れのトークンは 401 を返す" do
      token = issue_token

      travel 2.hours + 1.second do
        get api_v1_products_path, headers: bearer(token)
      end

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/products" do
    let(:body) { { name: "有機緑茶 100g" }.to_json }

    it "read スコープだけのトークンでは 403 を返す", :aggregate_failures do
      expect do
        post api_v1_products_path, params: body, headers: bearer(issue_token).merge("Content-Type" => "application/json")
      end.not_to change(Catalog::Product, :count)

      expect(response).to conform_schema(403)
      expect(json).to eq("error" => "insufficient_scope")
    end

    it "write スコープのトークンで登録できる" do
      token = issue_token(scope: "read write")

      post api_v1_products_path, params: body, headers: bearer(token).merge("Content-Type" => "application/json")

      expect(response).to conform_schema(201)
    end
  end
end
