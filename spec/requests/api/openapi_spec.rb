require "rails_helper"

RSpec.describe "api/openapi.yaml", type: :request do
  it "OpenAPI 3.1 のドキュメントとして正しい" do
    expect(skooma_openapi_schema).to be_valid_document
  end

  # The same check runs as bin/rails structured_params:openapi:drift_check.
  it "Api::*RequestParameter が request の schema と一致する", :aggregate_failures do
    Rails.autoloaders.main.eager_load_dir(Rails.root.join("app/parameters"))

    results = StructuredParams::OpenAPI::Registry.check_all(auto_discover: true)

    expect(results.map { it.parameter_class.name }).to include(
      "Api::V1::Products::CreateRequestParameter", "Api::V1::Skus::UpdateRequestParameter"
    )
    expect(results).to all(be_valid), -> { results.reject(&:valid?).map(&:to_message).join("\n\n") }
  end
end
