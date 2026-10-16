# JSON API. Two kinds of callers:
# - the Next.js back office and /api/docs, with the Devise session cookie shared with /console
#   (same origin, so no CORS);
# - other systems, with a Bearer token from the client credentials grant (POST /oauth/token).
class Api::V1::BaseController < ActionController::API
  include Pagy::Method
  include Doorkeeper::Rails::Helpers

  # Parameter classes read the request body as is, so don't copy it under a "product" key.
  wrap_parameters false

  before_action :authenticate_api_client!
  # Browsers can't send a cross-site application/json request without a CORS preflight, which
  # this API never allows. Together with the SameSite=Lax session cookie this blocks CSRF.
  # Bearer tokens are never sent by the browser on its own, so they need no such check.
  before_action :require_json_body, if: -> { request.post? || request.put? || request.patch? }

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "not_found" }, status: :not_found
  end

  private

  # A request with an Authorization header is judged by its token alone, so a bad token is
  # rejected even when the same browser also has a session.
  def authenticate_api_client!
    if request.authorization.present?
      authenticate_with_token!
    elsif !admin_signed_in?
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

  def authenticate_with_token!
    if !doorkeeper_token&.accessible?
      response.headers["WWW-Authenticate"] = %(Bearer error="invalid_token")
      render json: { error: "invalid_token" }, status: :unauthorized
    elsif !doorkeeper_token.includes_scope?(required_scope)
      response.headers["WWW-Authenticate"] = %(Bearer error="insufficient_scope", scope="#{required_scope}")
      render json: { error: "insufficient_scope" }, status: :forbidden
    end
  end

  # Admins signed in through the session may do everything their role allows; tokens need
  # the write scope for anything that changes data.
  def required_scope
    request.get? || request.head? ? "read" : "write"
  end

  def require_json_body
    return if request.media_type == Mime[:json].to_s

    render json: { error: "unsupported_media_type" }, status: :unsupported_media_type
  end

  def render_validation_errors(errors)
    render json: { errors: nested_errors(errors) }, status: :unprocessable_content
  end

  # Nests error keys so the client can follow the request body. Parameter classes use
  # "skus.0.code" and Active Record uses "skus[0].code"; both become
  # {"skus" => {"0" => {"code" => [...]}}}.
  def nested_errors(errors)
    errors.to_hash.each_with_object({}) do |(key, messages), result|
      *parents, leaf = key.to_s.gsub(/\[(\d+)\]/, '.\1').split(".")
      parents.reduce(result) { |hash, part| hash[part] ||= {} }[leaf] = messages
    end
  end

  # PATCH changes only the keys the client sent. Parameter classes return every attribute, with
  # nil for the missing ones, so look at the request body to tell "absent" from "null".
  def sent_attributes(request_params)
    request_params.attributes.slice(*request.request_parameters.keys)
  end

  def pagination(pagy)
    { page: pagy.page, per_page: pagy.limit, count: pagy.count, pages: pagy.pages }
  end
end
