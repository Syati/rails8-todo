require "rails_helper"

RSpec.describe "Admins::Destroy", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:super_admin) { create(:admin, :super_admin) }
  let(:operator) { create(:admin) }
  let!(:target_admin) { create(:admin, email: "target@example.com") }

  describe "DELETE /admins/:id" do
    context "when super_admin" do
      before { sign_in super_admin }

      it "論理削除して一覧へリダイレクトする", :aggregate_failures do
        expect { delete admin_path(target_admin) }.not_to change(Admin, :count)

        expect(target_admin.reload).to be_discarded
        expect(response).to redirect_to(admins_path)
        expect(flash[:notice]).to eq("target@example.com を削除しました。")
      end

      it "削除した管理者は一覧に表示しない" do
        delete admin_path(target_admin)
        get admins_path

        expect(response.body).not_to include(">#{target_admin.id}</td>")
      end

      it "削除した管理者の詳細は404になる" do
        delete admin_path(target_admin)
        get admin_path(target_admin)

        expect(response).to have_http_status(:not_found)
      end

      it "自分自身は削除できない", :aggregate_failures do
        delete admin_path(super_admin)

        expect(super_admin.reload).not_to be_discarded
        expect(response).to redirect_to(admin_path(super_admin))
        expect(flash[:alert]).to eq("自分自身のアカウントは削除できません。")
      end
    end

    it "operator は403で削除できない", :aggregate_failures do
      sign_in operator

      delete admin_path(target_admin)

      expect(response).to have_http_status(:forbidden)
      expect(target_admin.reload).not_to be_discarded
    end

    it "未ログインはログイン画面へリダイレクトする" do
      delete admin_path(target_admin)

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "削除された管理者のログイン" do
    before { target_admin.discard }

    it "ログインできない", :aggregate_failures do
      post admin_session_path, params: { admin: { email: "target@example.com", password: "password123" } }

      expect(response).to redirect_to(new_admin_session_path)
      expect(flash[:alert]).to eq("このアカウントは削除されています。")
    end

    it "ログイン中に削除されたセッションは無効になる" do
      sign_in target_admin

      get admins_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end
end
