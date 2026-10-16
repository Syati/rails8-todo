# OAuth 2 for API clients such as other in-house systems. They get a token with the client
# credentials grant (POST /oauth/token) and call /api/v1 with "Authorization: Bearer <token>".
# The back office itself keeps using the Devise session; see Api::V1::BaseController.
Doorkeeper.configure do
  orm :active_record

  grant_flows %w[client_credentials]

  # GET needs read; POST, PATCH and DELETE need write.
  default_scopes :read
  optional_scopes :write
  enforce_configured_scopes

  access_token_expires_in 2.hours

  # Store only digests, so a leaked database does not leak usable credentials.
  # The client secret is shown once, right after the application is registered.
  hash_token_secrets
  hash_application_secrets

  # /oauth/applications is limited to super_admins, like the other settings that hand out access.
  # Doorkeeper's controllers define their own authenticate_admin! that runs this block, which
  # shadows Devise's helper of the same name, so ask Warden for the login directly.
  base_controller "ApplicationController"
  admin_authenticator do
    warden.authenticate!(scope: :admin)
    render "shared/forbidden", layout: "application", status: :forbidden unless current_admin.super_admin?
  end
end
