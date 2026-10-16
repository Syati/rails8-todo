require "rails_helper"

RSpec.describe "OAuth applications", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "登録" do
    let(:application) { Doorkeeper::Application.last }

    before do
      sign_in create(:admin, :super_admin)
      post oauth_applications_path, params: { doorkeeper_application: { name: "倉庫システム", scopes: "read write", confidential: "1" } }
    end

    it "登録直後の詳細に secret を一度だけ出し、flash のアラートには出さない", :aggregate_failures do
      follow_redirect!

      expect(response.body).to include(application.uid, "secret はこの画面でしか表示しません")
      expect(response.body.scan(%r{<span class="break-all font-mono text-gray-900">[^<]+</span>}).size).to eq(1)
      expect(response.body).not_to include("border-red-200")
    end

    it "secret はハッシュだけを保存し、あとからは表示しない", :aggregate_failures do
      follow_redirect!
      get oauth_application_path(application)

      expect(response.body).to include("ハッシュで保存しているため表示できません")
      # Only the SHA-256 digest is stored (hash_application_secrets).
      expect(application.secret).to match(/\A\h{64}\z/)
    end
  end

  it "サイドバーのリンクは super_admin にだけ出す", :aggregate_failures do
    sign_in create(:admin, :super_admin)
    get console_products_path
    expect(response.body).to include(%(href="#{oauth_applications_path}"))

    sign_in create(:admin)
    get console_products_path
    expect(response.body).not_to include(%(href="#{oauth_applications_path}"))
  end

  it "一覧と編集画面をコンソールのレイアウトで表示する", :aggregate_failures do
    sign_in create(:admin, :super_admin)
    application = create(:oauth_application, name: "倉庫システム")

    get oauth_applications_path
    expect(response.body).to include("倉庫システム", %(id="application-sidebar"))

    get edit_oauth_application_path(application)
    expect(response.body).to include(%(<option selected="selected" value="read write">))
  end

  it "名前が空なら登録せずにフォームを出し直す" do
    sign_in create(:admin, :super_admin)

    expect do
      post oauth_applications_path, params: { doorkeeper_application: { name: "", scopes: "read" } }
    end.not_to change(Doorkeeper::Application, :count)
  end

  it "operator は 403 を返す" do
    sign_in create(:admin)

    get oauth_applications_path

    expect(response).to have_http_status(:forbidden)
  end

  it "未ログインはログイン画面へリダイレクトする" do
    get oauth_applications_path

    expect(response).to redirect_to(new_admin_session_path)
  end
end
