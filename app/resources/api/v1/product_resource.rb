# V1.Products.Product in api/openapi.yaml.
class Api::V1::ProductResource
  include Alba::Resource

  attributes :id, :name, :description, :status, :tax_rate
  many :skus, resource: Api::V1::SkuResource
  attributes :created_at, :updated_at
end
