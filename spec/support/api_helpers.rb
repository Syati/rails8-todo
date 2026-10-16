# Headers for calling /api/v1 with a client credentials token, without going through
# POST /oauth/token (client_credentials_spec covers that).
module ApiHelpers
  def api_headers(scopes: "read write", json: false)
    token = Doorkeeper::AccessToken.create!(application: create(:oauth_application), scopes:, expires_in: 2.hours)
    headers = { "Authorization" => "Bearer #{token.plaintext_token}" }
    json ? headers.merge("Content-Type" => "application/json") : headers
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
