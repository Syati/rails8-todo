require "rails_helper"

RSpec.describe "Admins::Index", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "GET /admins" do
    let!(:viewer) { create(:admin) }
    let!(:target_admin) { create(:admin, email: "target-admin@example.com") }
    let!(:other_admin) { create(:admin, email: "other-admin@example.com") }

    before do
      # rubocop:disable FactoryBot/ExcessiveCreateList
      create_list(:admin, 34)
      # rubocop:enable FactoryBot/ExcessiveCreateList
      sign_in viewer
    end

    it "管理者一覧を30件かつid降順で表示する" do
      get admins_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("管理者一覧")

      ordered_ids = Admin.order(id: :desc).limit(30).pluck(:id)
      hidden_ids = Admin.order(id: :desc).offset(30).pluck(:id)

      expect_ids_rendered_in_table(response.body, ordered_ids)
      expect_ids_hidden_from_table(response.body, hidden_ids)
    end

    it "idで検索できる" do
      get admins_path, params: { q: { id_eq: target_admin.id } }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(">#{target_admin.id}</td>")
      expect(response.body).not_to include(">#{other_admin.id}</td>")
    end

    it "emailで部分一致検索できる" do
      get admins_path, params: { q: { email_cont: "target-admin" } }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(target_admin.email)
      expect(response.body).not_to include(other_admin.email)
    end
  end

  def expect_ids_rendered_in_table(body, ids)
    ids.each do |id|
      expect(body).to include(">#{id}</td>")
    end
  end

  def expect_ids_hidden_from_table(body, ids)
    ids.each do |id|
      expect(body).not_to include(">#{id}</td>")
    end
  end
end
