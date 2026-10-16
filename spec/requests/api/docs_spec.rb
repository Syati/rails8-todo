require "rails_helper"

RSpec.describe "Api::Docs", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:operator) { create(:admin) }

  describe "GET /api/docs" do
    it "Stoplight Elements で openapi.yaml を表示する", :aggregate_failures do
      sign_in operator

      get api_docs_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(<elements-api), %(apiDescriptionUrl="#{api_docs_openapi_path}"))
    end

    it "未ログインはログイン画面へリダイレクトする" do
      get api_docs_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "GET /api/docs/openapi.yaml" do
    it "api/openapi.yaml を返す", :aggregate_failures do
      sign_in operator

      get api_docs_openapi_path

      expect(response).to have_http_status(:ok)
      expect(YAML.safe_load(response.body).dig("info", "title")).to eq("EC 受注管理 API")
    end
  end
end
