require "rails_helper"

RSpec.describe "Admins::Show", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "GET /admins/:id" do
    let(:viewer) { create(:admin) }
    let(:target_admin) { create(:admin, email: "target-admin@example.com") }

    context "when signed in" do
      before { sign_in viewer }

      it "管理者の詳細を表示する", :aggregate_failures do
        get admin_path(target_admin)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("管理者詳細")
        expect(response.body).to include(target_admin.email)
      end

      it "秘匿情報を表示しない", :aggregate_failures do
        target_admin.update!(current_sign_in_ip: "203.0.113.10")

        get admin_path(target_admin)

        expect(response.body).not_to include(target_admin.encrypted_password)
        expect(response.body).not_to include("203.0.113.10")
      end

      it "存在しないIDは404を返す" do
        get admin_path(id: Admin.maximum(:id).to_i + 1)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not signed in" do
      it "ログイン画面へリダイレクトする" do
        get admin_path(target_admin)

        expect(response).to redirect_to(new_admin_session_path)
      end
    end
  end
end
