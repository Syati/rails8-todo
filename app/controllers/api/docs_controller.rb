# API reference for logged-in admins, rendered by Stoplight Elements from api/openapi.yaml.
class Api::DocsController < ApplicationController
  OPENAPI_PATH = Rails.root.join("api/openapi.yaml")

  layout false

  def show
  end

  def openapi
    dev = Settings.dev_api_client
    return send_file(OPENAPI_PATH, type: "application/yaml", disposition: "inline") unless dev

    # The fixed development client (config/settings/development.yml) belongs to this environment
    # only, so add it to the Overview when serving instead of writing it into api/openapi.yaml.
    document = YAML.safe_load_file(OPENAPI_PATH)
    document["info"]["description"] += "\n\n#{dev_credentials_description(dev)}"
    render plain: document.to_yaml, content_type: "application/yaml"
  end

  private

  def dev_credentials_description(dev)
    <<~MARKDOWN
      ## 開発環境で試す

      `bin/rails db:seed` で、決まった値の開発用クライアントとトークンが入っています。

      | 項目 | 値 |
      | --- | --- |
      | トークン（期限なし） | `#{dev.access_token}` |
      | client_id | `#{dev.client_id}` |
      | client_secret | `#{dev.client_secret}` |

      「Send API Request」の Auth（BearerAuth）にトークンを入力すると試せます。
    MARKDOWN
  end
end
