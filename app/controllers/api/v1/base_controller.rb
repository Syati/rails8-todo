# JSON API for the Next.js back office. It shares the Devise session cookie with /console, so
# both run on the same origin and need no CORS or tokens.
class Api::V1::BaseController < ActionController::API
  include Pagy::Method

  # Parameter classes read the request body as is, so don't copy it under a "product" key.
  wrap_parameters false

  before_action :authenticate_api_admin!
  # Browsers can't send a cross-site application/json request without a CORS preflight, which
  # this API never allows. Together with the SameSite=Lax session cookie this blocks CSRF.
  before_action :require_json_body, if: -> { request.post? || request.put? || request.patch? }

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "not_found" }, status: :not_found
  end

  private

  def authenticate_api_admin!
    render json: { error: "unauthorized" }, status: :unauthorized unless admin_signed_in?
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
