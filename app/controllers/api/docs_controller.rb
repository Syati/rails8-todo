# API reference for logged-in admins, rendered by Stoplight Elements from api/openapi.yaml.
class Api::DocsController < ApplicationController
  layout false

  def show
  end

  def openapi
    send_file Rails.root.join("api/openapi.yaml"), type: "application/yaml", disposition: "inline"
  end
end
