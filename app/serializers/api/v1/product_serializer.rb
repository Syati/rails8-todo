# V1.Products.Product in api/openapi.yaml.
module Api::V1::ProductSerializer
  def self.call(product)
    {
      id: product.id,
      name: product.name,
      description: product.description,
      status: product.status,
      tax_rate: product.tax_rate,
      skus: product.skus.map { Api::V1::SkuSerializer.call(it) },
      created_at: product.created_at,
      updated_at: product.updated_at
    }
  end
end
