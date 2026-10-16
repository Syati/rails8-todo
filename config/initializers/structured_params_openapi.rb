# Compares app/parameters/api/**/*RequestParameter with the request schemas in api/openapi.yaml.
# Run with: bin/rails structured_params:openapi:drift_check
return unless defined?(StructuredParams::OpenAPI)

StructuredParams::OpenAPI.configure do |config|
  config.document = Rails.root.join("api/openapi.yaml").to_s
  # Query parameters (*QueryParameter) have no component schema to compare against.
  config.parameter_class_filter = ->(klass) { klass.name&.match?(/\AApi::.+RequestParameter\z/) }
  # Api::V1::Products::CreateRequestParameter -> "V1.Products.CreateRequest"
  config.schema_name_resolver = lambda do |klass|
    klass.name.delete_prefix("Api::").delete_suffix("Parameter").gsub("::", ".")
  end
end
