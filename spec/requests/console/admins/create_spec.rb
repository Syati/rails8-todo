require "rails_helper"

RSpec.describe "Console::Admins::Create", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:super_admin) { create(:admin, :super_admin) }
  let(:operator) { create(:admin) }
  let(:valid_params) do
    { admin: { email: "new-admin@example.com", password: "password123", password_confirmation: "password123" } }
  end

  describe "GET /console/admins/new" do
    it "super_admin は作成フォームを表示できる" do
      sign_in super_admin

      get new_console_admin_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("管理者の新規作成")
    end

    it "operator は403になる" do
      sign_in operator

      get new_console_admin_path

      expect(response).to have_http_status(:forbidden)
    end

    it "未ログインはログイン画面へリダイレクトする" do
      get new_console_admin_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "POST /console/admins" do
    context "when super_admin" do
      before { sign_in super_admin }

      it "operator ロールの管理者を作成して詳細へリダイレクトする", :aggregate_failures do
        expect { post console_admins_path, params: valid_params }.to change(Admin, :count).by(1)

        created = Admin.find_by!(email: "new-admin@example.com")
        expect(created).to be_operator
        expect(response).to redirect_to(console_admin_path(created))
        expect(flash[:notice]).to include("管理者を作成しました")
      end

      it "role を送っても operator で作成する" do
        post console_admins_path, params: { admin: valid_params[:admin].merge(role: "super_admin") }

        expect(Admin.find_by!(email: "new-admin@example.com")).to be_operator
      end

      it "確認メールを送信する" do
        expect { post console_admins_path, params: valid_params }
          .to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      it "メールアドレスが重複していると422でフォームを再表示する", :aggregate_failures do
        create(:admin, email: "new-admin@example.com")

        expect { post console_admins_path, params: valid_params }.not_to change(Admin, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("管理者の新規作成")
        expect(response.body).to include("すでに存在します")
      end

      it "メールアドレスの形式が不正だと作成しない" do
        post console_admins_path, params: { admin: valid_params[:admin].merge(email: "not-an-email") }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("は不正な値です")
      end

      it "パスワードが短いと作成しない" do
        post console_admins_path, params: { admin: valid_params[:admin].merge(password: "short", password_confirmation: "short") }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("文字以上で入力してください")
      end

      it "パスワード確認が一致しないと作成しない" do
        post console_admins_path, params: { admin: valid_params[:admin].merge(password_confirmation: "different123") }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("一致しません")
      end
    end

    it "operator は403で作成できない", :aggregate_failures do
      sign_in operator

      expect { post console_admins_path, params: valid_params }.not_to change(Admin, :count)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
