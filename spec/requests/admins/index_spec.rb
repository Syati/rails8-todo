require "rails_helper"

RSpec.describe "Admins::Index", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "GET /admins" do
    let!(:viewer) { create(:admin) }

    before do
      create_list(:admin, 34)
      sign_in viewer
    end

    it "管理者一覧を30件かつid降順で表示する" do
      get admins_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("管理者一覧")

      ordered_ids = Admin.order(id: :desc).limit(30).pluck(:id)
      hidden_ids = Admin.order(id: :desc).offset(30).pluck(:id)

      ordered_ids.each do |id|
        expect(response.body).to include("<td>#{id}</td>")
      end

      hidden_ids.each do |id|
        expect(response.body).not_to include("<td>#{id}</td>")
      end
    end
  end
end
