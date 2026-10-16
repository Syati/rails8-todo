# An API client with fixed credentials, plus a token that never expires, so the API can be
# called locally without registering a client first. Values are in config/settings/development.yml.
dev = Settings.dev_api_client
digest = ->(plain) { Doorkeeper::SecretStoring::Sha256Hash.transform_secret(plain) }

# uid and secret are kept as given; the secret is stored hashed like the ones Doorkeeper creates.
application = Doorkeeper::Application.find_or_create_by!(uid: dev.client_id) do |app|
  app.name = "開発用クライアント"
  app.secret = digest.call(dev.client_secret)
  app.scopes = "read write"
end

unless Doorkeeper::AccessToken.exists?(token: digest.call(dev.access_token))
  # Doorkeeper always generates its own token on create, so replace it with the fixed one after.
  token = Doorkeeper::AccessToken.create!(application:, scopes: "read write", expires_in: nil)
  token.update!(token: digest.call(dev.access_token))
end
