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

    it "開発用クライアントの設定があれば、その値を表示する" do
      sign_in operator
      allow(Settings).to receive(:dev_api_client)
        .and_return(Config::Options.new(client_id: "dev-client", client_secret: "dev-secret", access_token: "dev-token"))

      get api_docs_path

      expect(response.body).to include("<code>Bearer dev-token</code>", "<code>dev-client</code>")
    end

    it "開発用クライアントの設定がなければ表示しない" do
      sign_in operator

      get api_docs_path

      expect(response.body).not_to include("dev-credentials\" role")
    end

    it "未ログインはログイン画面へリダイレクトする" do
      get api_docs_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "サイドバー" do
    it "開発者向けに API リファレンスへのリンクを出す" do
      sign_in operator

      get console_products_path

      expect(response.body).to include(%(href="#{api_docs_path}" target="_blank"))
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
