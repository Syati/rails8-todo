# V1.Skus.Sku in api/openapi.yaml.
class Api::V1::SkuResource
  include Alba::Resource

  attributes :id, :code, :size, :color, :price_yen, :stock_quantity
end
