class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :authenticate_admin!, unless: :devise_controller?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern


  def switch_locale(&action)
    locale = params[:locale] || session[:locale] || I18n.default_locale
    session[:locale] = locale
    I18n.with_locale(locale, &action)
  end
end
