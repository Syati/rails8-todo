require "rails_helper"

RSpec.describe "Admins::Update", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:super_admin) { create(:admin, :super_admin) }
  let(:operator) { create(:admin) }
  let(:target_admin) { create(:admin, email: "target@example.com") }

  describe "GET /admins/:id/edit" do
    it "super_admin は編集フォームを表示できる" do
      sign_in super_admin

      get edit_admin_path(target_admin)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("管理者の編集")
    end

    it "operator は403になる" do
      sign_in operator

      get edit_admin_path(target_admin)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /admins/:id" do
    context "when super_admin" do
      before { sign_in super_admin }

      it "ロールを更新して詳細へリダイレクトする", :aggregate_failures do
        patch admin_path(target_admin), params: { admin: { role: "super_admin" } }

        expect(target_admin.reload).to be_super_admin
        expect(response).to redirect_to(admin_path(target_admin))
        expect(flash[:notice]).to eq("管理者を更新しました。")
      end

      it "メールアドレスの変更は確認待ちにする", :aggregate_failures do
        patch admin_path(target_admin), params: { admin: { email: "changed@example.com" } }

        target_admin.reload
        expect(target_admin.email).to eq("target@example.com")
        expect(target_admin.unconfirmed_email).to eq("changed@example.com")
        expect(flash[:notice]).to include("changed@example.com に確認メールを送信しました")
      end

      it "パスワードが空なら現在のパスワードを維持する" do
        patch admin_path(target_admin), params: { admin: { role: "operator", password: "", password_confirmation: "" } }

        expect(target_admin.reload.valid_password?("password123")).to be(true)
      end

      it "パスワードを変更できる" do
        patch admin_path(target_admin), params: { admin: { password: "newpassword1", password_confirmation: "newpassword1" } }

        expect(target_admin.reload.valid_password?("newpassword1")).to be(true)
      end

      it "自分のロールは変更できない" do
        patch admin_path(super_admin), params: { admin: { role: "operator" } }

        expect(super_admin.reload).to be_super_admin
      end

      it "不正なメールアドレスは422でフォームを再表示する", :aggregate_failures do
        patch admin_path(target_admin), params: { admin: { email: "not-an-email" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("管理者の編集")
        expect(response.body).to include("は不正な値です")
        expect(target_admin.reload.unconfirmed_email).to be_nil
      end

      it "パスワード確認が一致しないと422になる" do
        patch admin_path(target_admin), params: { admin: { password: "newpassword1", password_confirmation: "other12345" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(target_admin.reload.valid_password?("password123")).to be(true)
      end

      it "未定義のロールは422になる" do
        patch admin_path(target_admin), params: { admin: { role: "owner" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(target_admin.reload).to be_operator
      end
    end

    it "operator は403で更新できない", :aggregate_failures do
      sign_in operator

      patch admin_path(target_admin), params: { admin: { role: "super_admin" } }

      expect(response).to have_http_status(:forbidden)
      expect(target_admin.reload).to be_operator
    end

    it "未ログインはログイン画面へリダイレクトする" do
      patch admin_path(target_admin), params: { admin: { role: "super_admin" } }

      expect(response).to redirect_to(new_admin_session_path)
    end
  end
end
