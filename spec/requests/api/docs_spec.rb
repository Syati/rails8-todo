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
      info = YAML.safe_load(response.body)["info"]
      expect(info["title"]).to eq("EC 受注管理 API")
      expect(info["description"]).not_to include("開発環境で試す")
    end

    it "開発用クライアントの設定があれば、Overview の末尾に値を足す", :aggregate_failures do
      sign_in operator
      allow(Settings).to receive(:dev_api_client)
        .and_return(Config::Options.new(client_id: "dev-client", client_secret: "dev-secret", access_token: "dev-token"))

      get api_docs_openapi_path

      description = YAML.safe_load(response.body).dig("info", "description")
      expect(description).to start_with("EC 受注管理システムの JSON API。")
      expect(description).to include("## 開発環境で試す", "`dev-token`", "`dev-client`", "`dev-secret`")
    end
  end
end
