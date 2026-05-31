require "rails_helper"

RSpec.describe "Admins::Sessions", type: :request do
  describe "GET /admins/sign_in" do
    it "returns success and renders Flowbite login structure" do
      get new_admin_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Admin Login")
      expect(response.body).to include("flowbite")
      expect(response.body).to include("rounded-lg border border-gray-200 bg-white")
    end

    it "does not render AdminLTE or CDN assets" do
      get new_admin_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("login-box")
      expect(response.body).not_to include("javascripts/adminlte.min")
      expect(response.body).not_to include("cdn.jsdelivr.net")
    end
  end
end
