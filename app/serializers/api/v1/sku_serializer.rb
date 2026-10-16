# V1.Skus.Sku in api/openapi.yaml.
module Api::V1::SkuSerializer
  def self.call(sku)
    sku.slice(:id, :code, :size, :color, :price_yen, :stock_quantity)
  end
end
