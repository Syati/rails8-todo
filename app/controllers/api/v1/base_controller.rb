# JSON API. Callers get a token with the OAuth 2 client credentials grant (POST /oauth/token,
# see config/initializers/doorkeeper.rb) and send it as "Authorization: Bearer <token>".
class Api::V1::BaseController < ActionController::API
  include Pagy::Method
  include Doorkeeper::Rails::Helpers

  # Parameter classes read the request body as is, so don't copy it under a "product" key.
  wrap_parameters false

  before_action :authenticate_api_client!
  before_action :require_json_body, if: -> { request.post? || request.put? || request.patch? }

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "not_found" }, status: :not_found
  end

  private

  # Answers with the error codes of RFC 6750 so OAuth clients can tell a missing or expired
  # token (get a new one) from a missing scope (register the client with write).
  def authenticate_api_client!
    if request.authorization.blank?
      response.headers["WWW-Authenticate"] = "Bearer"
      render json: { error: "unauthorized" }, status: :unauthorized
    # doorkeeper_token is nil for a token that was never issued.
    elsif !doorkeeper_token&.accessible?
      response.headers["WWW-Authenticate"] = %(Bearer error="invalid_token")
      render json: { error: "invalid_token" }, status: :unauthorized
    elsif !doorkeeper_token.includes_scope?(required_scope)
      response.headers["WWW-Authenticate"] = %(Bearer error="insufficient_scope", scope="#{required_scope}")
      render json: { error: "insufficient_scope" }, status: :forbidden
    end
  end

  # GET needs read; anything that changes data needs write.
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
