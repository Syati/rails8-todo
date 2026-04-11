class FaqController < ApplicationController
  skip_before_action :authenticate_admin!
  layout "auth"

  def index
  end
end
